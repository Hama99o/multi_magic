import { http } from '@/services/http.service';

class FollowAPI {
  async createFollow(followed_id: number) {
    try {
      const res = await http.post(`/api/v1/follows/follow`, { followed_id });
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async deleteFollow(followed_id: number) {
    const res = await http.post(`/api/v1/follows/unfollow`, { followed_id });
    return res.data;
  }
}

const instance = new FollowAPI();

export default instance;
