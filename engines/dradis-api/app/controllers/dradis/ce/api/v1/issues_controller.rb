module Dradis::CE::API
  module V1
    class IssuesController < Dradis::CE::API::V1::ProjectScopedController
      def index
        issuelib = Node.issue_library
        @issues  = Issue.where(node_id: issuelib.id).includes(:tags).sort
      end

      def show
        @issue = Issue.find(params[:id])
      end

      def create
        @issue = Issue.new(issue_params)
        @issue.author   = current_user.email
        @issue.category = Category.issue
        @issue.node     = Node.issue_library

        if @issue.save
          track_created(@issue)
          render status: 201, location: dradis_api.issue_url(@issue)
        else
          render_validation_errors(@issue)
        end
      end

      def update
        @issue = Issue.find(params[:id])
        if @issue.update_attributes(issue_params)
          track_updated(@issue)
          render node: @node
        else
          render_validation_errors(@issue)
        end
      end

      def destroy
        @issue = Issue.find(params[:id])
        @issue.destroy
        track_destroyed(@issue)
        render_successful_destroy_message
      end

      private
      def issue_params
        params.require(:issue).permit(:text)
      end
    end
  end
end
