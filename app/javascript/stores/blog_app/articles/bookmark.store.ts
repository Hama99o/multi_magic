// app/javascript/stores/blog_app/articles/bookmark.store.ts
import { defineStore } from 'pinia';
import BookmarkAPI from '@/apis/blog_app/articles/bookmark.api';

export const useBookmarkStore = defineStore({
  id: 'bookmark-store',
  state: () => ({
    bookmarks: [],
    articleId: null,
  }),
  getters: {
    // Optionally, add any getters here if needed for filtering or sorting bookmarks
  },
  actions: {
    // Fetch all bookmarks for a specific article
    async fetchBookmarks(articleId) {
      this.articleId = articleId;
      const res = await BookmarkAPI.fetchBookmarks(articleId);
      this.bookmarks = res.bookmarks;
      return res.bookmarks;
    },

    // Create a new bookmark for the current article
    async createBookmark() {
      if (!this.articleId) throw new Error('Article ID not set');
      const res = await BookmarkAPI.createBookmark(this.articleId);
      const newBookmark = res.bookmark;
      this.bookmarks.push(newBookmark);
      return newBookmark;
    },

    // Delete a bookmark
    async deleteBookmark(bookmarkId) {
      if (!this.articleId) throw new Error('Article ID not set');
      const res = await BookmarkAPI.deleteBookmark(this.articleId, bookmarkId);
      this.bookmarks = this.bookmarks.filter(bookmark => bookmark.id !== bookmarkId);
      return res.bookmark;
    }
  }
});
