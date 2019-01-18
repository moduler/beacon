class IssueCommentsController < ApplicationController
  before_action :authenticate_account!
  before_action :scope_project
  before_action :scope_issue
  before_action :enforce_permissions

  def create
    comment = IssueComment.create(
      issue_id: @issue.id,
      commenter_id: current_account.id,
      visible_to_reporter: visible_to_reporter?,
      visible_to_respondent: visible_to_respondent?,
      visible_only_to_moderators: visible_only_to_moderators?,
      text: comment_params[:text]
    )
    notify_of_new_comment(comment)
    redirect_to project_issue_path(@project, @issue)
  end

  private

  def comment_params
    params.require(:issue_comment).permit(
      :text,
      :visible_to_reporter,
      :visible_to_respondent,
      :visible_only_to_moderators
    )
  end

  def enforce_permissions
    render(status: :forbidden, plain: nil) && return unless current_account.can_comment_on_issue?(@issue)
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

  def scope_issue
    @issue = Issue.find(params[:issue_id])
  end

  def notify_of_new_comment(comment)
    return if comment.visible_only_to_moderators && comment.commenter == current_account
    email = if comment.visible_to_reporter && @project.moderator?(comment.commenter)
              @issue.reporter.email
            elsif comment.visible_to_respondent && @project.moderator?(comment.commenter)
              @issue.respondent.email
            else
              @project.moderators.map(&:email)
            end
    IssueNotificationsMailer.with(
      email: email,
      project: @issue.project,
      issue: @issue,
      commenter_kind: comment.commenter_kind
    ).notify_of_new_comment.deliver_now
  end

  def visible_only_to_moderators?
    comment_params[:visible_only_to_moderators] == '1' && @project.moderator?(current_account)
  end

  def visible_to_reporter?
    current_account == @issue.reporter || (@project.moderator?(current_account) && comment_params[:visible_to_reporter] == '1')
  end

  def visible_to_respondent?
    current_account == @issue.respondent || (@project.moderator?(current_account) && comment_params[:visible_to_respondent] == '1')
  end

end
