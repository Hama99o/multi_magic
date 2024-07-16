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
      this.comments.push(res.comment);
      return res.comment;
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
    }
  }
});
