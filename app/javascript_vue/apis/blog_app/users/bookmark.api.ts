// src/apis/blog_app/users/bookmark.api.js
import { http } from '@/services/http.service';

class UserBookmarkAPI {
  // Fetch all article bookmarks for the current user
  async fetchUserArticleBookmarks() {
    const headers = { 'Content-Type': 'application/json' };
    const res = await http.get(`/api/v1/blog_app/users/bookmarks/articles`, { headers });
    return res.data;
  }

  // Delete a bookmark by ID
  async deleteUserBookmark(bookmarkId) {
    const headers = { 'Content-Type': 'application/json' };
    const res = await http.delete(`/api/v1/blog_app/users/bookmarks/articles/${bookmarkId}`, { headers });
    return res.data;
  }
}

export default new UserBookmarkAPI();
