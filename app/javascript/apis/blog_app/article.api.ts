import { http } from '@/services/http.service';

class ArticleAPI {
  async fetchArticles(page = 1, search = '') {
    const headers = { 'Content-Type': 'application/json' };
    const res = await http.get(`/api/v1/blog_app/articles?page=${page}&search=${search}`, { headers });
    return res.data;
  }

  async fetchTrashesArticles(page = 1, search = '') {
    const res = await http.get(`/api/v1/blog_app/articles/trashes?page=${page}&search=${search}`);
    return res.data;
  }

  async fetchDraftsArticles(page = 1, search = '') {
    const res = await http.get(`/api/v1/blog_app/articles/drafts?page=${page}&search=${search}`);
    return res.data;
  }

  async fetchArticle(id: number) {
    const headers = { 'Content-Type': 'application/json' };
    const res = await http.get(`/api/v1/blog_app/articles/${id}`, { headers });
    return res.data;
  }

  async createArticle(data) {
    const headers = { 'Content-Type': 'application/json' };
    const res = await http.post(`/api/v1/blog_app/articles`, data, { headers });
    return res.data;
  }

  async updateArticle(id: number, data = null) {
    const headers = { 'Content-Type': 'application/json' };
    const res = await http.put(`/api/v1/blog_app/articles/${id}`, data);
    return res.data;
  }

  async deleteArticle(id: number) {
    const headers = { 'Content-Type': 'application/json' };
    const res = await http.delete(`/api/v1/blog_app/articles/${id}`, { headers });
    return res.data;
  }

  async articleDeletePermanently(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/blog_app/articles/${id}/destroy_permanently`);
    return res.data;
  }
  async articleRestore(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/blog_app/articles/${id}/restore`);
    return res.data;
  }
  async toggleTag(id: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.post(`/api/v1/blog_app/articles/${id}/toggle_tag`, data, { headers });
    return res.data;
  }
}

const instance = new ArticleAPI();
export default instance;
