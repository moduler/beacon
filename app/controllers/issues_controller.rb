class IssuesController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_project
  before_action :scope_issue, except: [:index, :new, :create]
  before_action :scope_comments, only: [:show, :update]
  before_action :enforce_viewing_permissions, only: [:show]
  before_action :enforce_moderation_permissions, only: [:acknowledge, :dismiss, :resolve, :reopen, :update]
  before_action :enforce_upload_permissions, only: [:upload]
  before_action :enforce_issue_creation_permissions, only: [:new, :create]

  def index
    issues = current_account.issues
    @open_issues = issues.select(&:open?)
    @closed_issues = issues - @open_issues
  end

  def new
    @issue = Issue.new(project_id: @project.id, reporter_id: current_account.id)
  end

  def create
    @issue = Issue.new(issue_params.merge(project_id: @project.id, reporter_id: current_account.id))
    if verify_recaptcha(model: @issue) && @issue.save
      notify_on_new_issue
      redirect_to project_issue_path(@project, @issue)
    else
      flash[:error] = @issue.errors.full_messages
      render :new
    end
  end

  def upload
    if verify_recaptcha(model: @issue) && @issue.update_attributes(uploads: issue_params[:uploads])
      redirect_to project_issue_path(@project, @issue)
    else
      flash[:error] = @issue.errors.full_messages
      render :show
    end
  end

  def update
    @issue.update_attributes(issue_params)
    redirect_to project_issue_path(@project, @issue)
  end

  def show
    @comment = IssueComment.new

    @internal_comments = @issue.comments_visible_only_to_moderators
    @reporter_discussion_comments = @issue.comments_visible_to_reporter
    @respondent_discussion_comments = @issue.comments_visible_to_respondent

    @issue_severity_level = @issue.issue_severity_level

    @notifications_for_internal_comments_count = (
      @internal_comments
        .map(&:notifications)
        .flatten & current_account.notifications
    ).size

    @notifications_for_reporter_comments_count = (
      @reporter_discussion_comments
        .map(&:notifications)
        .flatten & current_account.notifications
    ).size

    @notifications_for_respondent_comments_count = (
      @respondent_discussion_comments
        .map(&:notifications)
        .flatten & current_account.notifications
    ).size

    @reporter_block = @project.account_project_blocks.find_by(account_id: @issue.reporter.id)
    @respondent_block = @project.account_project_blocks.find_by(account_id: @issue.respondent.try(:id))

    NotificationService.notified!(account: current_account, issue_id: @issue.id)
  end

  def acknowledge
    @issue.acknowledge!(account_id: current_account.id)
    notify_on_status_change
    redirect_to [@project, @issue]
  end

  def dismiss
    @issue.dismiss!(account_id: current_account.id)
    notify_on_status_change
    redirect_to [@project, @issue]
  end

  def resolve
    @issue.update_attributes(
      resolution_text: issue_params[:resolution_text],
      resolved_at: DateTime.now
    )
    @issue.resolve!(account_id: current_account.id)
    notify_on_status_change
    redirect_to [@project, @issue]
  end

  def reopen
    @issue.update_attribute(:resolved_at, nil)
    @issue.reopen!(account_id: current_account.id)
    notify_on_status_change
    redirect_to [@project, @issue]
  end

  private

  def enforce_issue_creation_permissions
    render_forbidden && return unless current_account.can_open_issue_on_project?(@project)
  end

  def enforce_moderation_permissions
    render_forbidden && return unless current_account.can_moderate_project?(@project)
  end

  def enforce_upload_permissions
    render_forbidden && return unless current_account.can_upload_images_to_issue?(@issue)
  end

  def enforce_viewing_permissions
    render_forbidden && return unless current_account.can_view_issue?(@issue)
  end

  def issue_params
    params.require(:issue).permit(:description, :resolution_text, :issue_severity_level_id, uploads: [], urls: [])
  end

  def notify_on_new_issue
    @project.moderators.each do |moderator|
      NotificationService.notify(account: moderator, project_id: @project.id, issue_id: @issue.id)
    end
    IssueNotificationsMailer.with(
      email: @project.moderator_emails,
      project: @project,
      issue: @issue
    ).notify_of_new_issue.deliver_now
  end

  def notify_on_status_change
    emails = [@issue.reporter.email, @issue.respondent.try(:email), @project.moderator_emails - [current_account.email]].flatten.compact
    IssueNotificationsMailer.with(
      emails: emails,
      project: @project,
      issue: @issue
    ).notify_on_status_change.deliver_now
  end

  def scope_comments
    @reporter_discussion_comments = @issue.comments_visible_to_reporter
    @respondent_discussion_comments = @issue.comments_visible_to_respondent
    @internal_comments = @issue.comments_visible_only_to_moderators
    @comment = IssueComment.new
  end

  def scope_issue
    @issue = Issue.where(id: [params[:id], params[:issue_id]]).includes(:issue_comments).first
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

end
