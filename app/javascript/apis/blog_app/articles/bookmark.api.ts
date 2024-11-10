// app/javascript/apis/blog_app/articles/bookmark.api.ts
import { http } from '@/services/http.service';

class BookmarkAPI {
  // Fetch all bookmarks for a specific article
  async fetchBookmarks(articleId) {
    const headers = { 'Content-Type': 'application/json' };
    const res = await http.get(`/api/v1/blog_app/articles/${articleId}/bookmarks`, { headers });
    return res.data;
  }

  // Create a new bookmark for a specific article
  async createBookmark(articleId) {
    const headers = { 'Content-Type': 'application/json' };
    const res = await http.post(`/api/v1/blog_app/articles/${articleId}/bookmarks`, {}, { headers });
    return res.data;
  }

  // Delete a bookmark from a specific article
  async deleteBookmark(articleId, bookmarkId) {
    const headers = { 'Content-Type': 'application/json' };
    const res = await http.delete(`/api/v1/blog_app/articles/${articleId}/bookmarks/${bookmarkId}`, { headers });
    return res.data;
  }
}

const instance = new BookmarkAPI();

export default instance;
