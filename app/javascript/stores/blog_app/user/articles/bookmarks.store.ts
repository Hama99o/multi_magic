// src/stores/userArticleBookmarks.store.js
import { defineStore } from 'pinia';
import UserBookmarkAPI from '@/apis/blog_app/users/bookmark.api';

export const useUserArticleBookmarksStore = defineStore({
  id: 'user-article-bookmarks',
  state: () => ({
    articleBookmarks: [],
  }),
  actions: {
    // Fetch all article bookmarks for the current user
    async fetchUserArticleBookmarks() {
      const res = await UserBookmarkAPI.fetchUserArticleBookmarks();
      this.articleBookmarks = res.bookmarks;
      return this.articleBookmarks;
    },

    // Delete a specific bookmark by ID
    async deleteUserBookmark(bookmarkId) {
      await UserBookmarkAPI.deleteUserBookmark(bookmarkId);
      this.articleBookmarks = this.articleBookmarks.filter(bookmark => bookmark.id !== bookmarkId);
    }
  }
});
