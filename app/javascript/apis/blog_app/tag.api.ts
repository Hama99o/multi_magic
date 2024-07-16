import { http } from '@/services/http.service';

class TagAPI {
  async fetchTags(search = '') {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.get(`/api/v1/blog_app/tags?search=${search}`, { headers });
    return res.data;
  }

  async createTag(data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.post(`/api/v1/blog_app/tags`, data, { headers });
    return res.data;
  }
  async updateTag(id: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/blog_app/tags/${id}`, data);
    return res.data;
  }
  async deleteTag(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/blog_app/tags/${id}`, { headers });
    return res.data;
  }
}

const instance = new TagAPI();

export default instance;
