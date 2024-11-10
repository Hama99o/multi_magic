import { http } from '@/services/http.service';

class ReactionAPI {
  // Fetch all reactions for a specific article
  async fetchReactions(articleId) {
    const headers = { 'Content-Type': 'application/json' };
    const res = await http.get(`/api/v1/blog_app/articles/${articleId}/reactions`, { headers });
    return res.data;
  }

  // Create a new reaction for a specific article
  async createReaction(articleId, data) {
    const headers = { 'Content-Type': 'application/json' };
    const res = await http.post(`/api/v1/blog_app/articles/${articleId}/reactions`, data, { headers });
    return res.data;
  }

  // Delete a reaction from a specific article
  async deleteReaction(articleId, reactionId) {
    const headers = { 'Content-Type': 'application/json' };
    const res = await http.delete(`/api/v1/blog_app/articles/${articleId}/reactions`, { headers });
    return res.data;
  }
}

const instance = new ReactionAPI();

export default instance;
