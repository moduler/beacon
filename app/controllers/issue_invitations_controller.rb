class IssueInvitationsController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_all
  before_action :enforce_permissions

  def new
    @invitation = IssueInvitation.new
  end

  def create
    if invitation_params[:summary].empty? || invitation_params[:email].empty?
      flash[:error] = "You must provide an email and an issue summary for the respondent."
      render :new && return
    end

    normalized_email = Normailize::EmailAddress.new(invitation_params[:email]).normalized_address

    if account = Account.find_by(normalized_email: normalized_email)
      AccountIssue.create(account: account, issue_id: @issue.id)
      @issue.update_attribute(:respondent_encrypted_id, EncryptionService.encrypt(account.id))
      RespondentMailer.with(
        email: account.email,
        project_name: @issue.project.name
      ).notify_existing_account_of_issue.deliver_now
    else
      IssueInvitation.create(
        email: Normailize::EmailAddress.new(invitation_params[:email]).normalized_address,
        issue_encrypted_id: EncryptionService.encrypt(@issue.id)
      )
      RespondentMailer.with(
        email: invitation_params[:email],
        project_name: @project.name,
        url: new_account_registration_url
      ).notify_new_account_of_issue.deliver_now
    end
    @issue.update_attribute(:respondent_summary, invitation_params[:summary])
    flash[:message] = "The respondent has been notified and invited to comment on this issue."
    redirect_to project_issue_path(@project, @issue)
  end

  private

  def enforce_permissions
    render(status: :forbidden, plain: nil) && return unless @issue.account_can_invite_respondent?(current_account)
  end

  def scope_all
    @project = Project.find_by(slug: params[:project_slug])
    @issue = Issue.find(params[:issue_id])
  end

  def invitation_params
    params[:issue_invitation].permit(:email, :summary)
  end

end
