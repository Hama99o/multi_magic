import { http } from '@/services/http.service';

class CommentAPI {
  // Fetch all comments for a specific article
  async fetchComments(articleId: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.get(`/api/v1/blog_app/articles/${articleId}/comments`, { headers });
    return res.data;
  }

  // Create a new comment for a specific article
  async createComment(articleId: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.post(`/api/v1/blog_app/articles/${articleId}/comments`, data, { headers });
    return res.data;
  }

  // Update an existing comment on a specific article
  async updateComment(articleId: number, commentId: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/blog_app/articles/${articleId}/comments/${commentId}`, data, { headers });
    return res.data;
  }

  // Delete a comment from a specific article
  async deleteComment(articleId: number, commentId: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/blog_app/articles/${articleId}/comments/${commentId}`, { headers });
    return res.data;
  }
}

const instance = new CommentAPI();

export default instance;
