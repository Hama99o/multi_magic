import { http } from '@/services/http.service';

class BlockAPI {
  async createBlock(blocked_id: number, data: {}) {
    try {
      const res = await http.post(`/api/v1/blocks/block`, { blocked_id });
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async deleteBlock(blocked_id: number) {
    const res = await http.post(`/api/v1/blocks/unblock`, { blocked_id });
    return res.data;
  }
}

const instance = new BlockAPI();

export default instance;
