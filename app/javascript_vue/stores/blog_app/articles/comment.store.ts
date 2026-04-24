import { defineStore } from 'pinia';
import CommentAPI from '@/apis/blog_app/articles/comment.api';

export const useCommentStore = defineStore({
  id: 'comment-store',
  state: () => ({
    comments: [],
    articleId: null,
    comment: null,
    pagination: {},
    page: 1,
  }),
  getters: {},
  actions: {
    // Fetch all comments for a specific article
    async fetchComments(articleId: number) {
      this.articleId = articleId;
      const res = await CommentAPI.fetchComments(articleId);
      this.comments = res.comments;
      return res.comments;
    },

    // Create a new comment for the current article
    async createComment(commentData: { body: string, parentId?: number }) {
      if (!this.articleId) throw new Error('Article ID not set');
      const res = await CommentAPI.createComment(this.articleId, { comment: commentData });
      const newComment = res.comment;

      if (newComment.parent_id) {
        // Insert as a reply in the right nested place
        this.insertReply(this.comments, newComment);
      } else {
        // Insert as a top-level comment
        this.comments.push(newComment);
      }

      return newComment;
    },

    // Update an existing comment
    async updateComment(commentId: number, commentData: { body: string }) {
      if (!this.articleId) throw new Error('Article ID not set');
      const res = await CommentAPI.updateComment(this.articleId, commentId, { comment: commentData });
      const index = this.comments.findIndex(comment => comment.id === commentId);
      if (index !== -1) this.comments[index] = res.comment;
      return res.comment;
    },

    // Delete a comment
    async deleteComment(commentId: number) {
      if (!this.articleId) throw new Error('Article ID not set');
      const res = await CommentAPI.deleteComment(this.articleId, commentId);
      this.comments = this.comments.filter(comment => comment.id !== commentId);
      return res.comment;
    },

    // Helper function to recursively find the correct parent and insert the reply
    insertReply(comments: any[], newComment: any) {
      for (let comment of comments) {
        if (comment.id === newComment.parent_id) {
          // Found the parent comment; add the new comment to its replies
          comment.replies.push(newComment);
          return true;
        } else if (comment.replies && comment.replies.length > 0) {
          // Recursively search in nested replies
          if (this.insertReply(comment.replies, newComment)) {
            return true;
          }
        }
      }
      return false; // Parent not found in current level
    }
  }
});
