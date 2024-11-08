import { defineStore } from 'pinia';
import ArticleAPI from '@/apis/blog_app/article.api.ts';

export const useArticleStore = defineStore({
  id: 'article-store',
  state: () => ({
    article: {},
    articles: [],
    trashesArticles: [],
    draftsArticles: [],
    search: '',
    draftSearch: '',
    trasheSearch: '',
    pagination: {},
    trashesArticlesPagination: {},
    draftsArticlesPagination: {},
    loading: false,
    page: 1,
    draftPage: 1,
    trashPage: 1,
  }),
  getters: {},
  actions: {
    async fetchArticles() {
      const res = await ArticleAPI.fetchArticles(this.page, this.search);
      this.articles = res.articles;
      this.pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
      return res.articles;
    },
    async fetchTrashesArticles() {
      this.loading = true;
      const res = await ArticleAPI.fetchTrashesArticles(this.trashPage, this.trasheSearch);
      this.trashesArticles = res?.articles;
      this.trashesArticlesPagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
    },
    async toggleTag(id: number, tagId: number) {
      const res = await ArticleAPI.toggleTag(id, { tag_ids: tagId });
      return res.article;
    },
    async fetchDraftsArticles() {
      this.loading = true;
      const res = await ArticleAPI.fetchDraftsArticles(this.draftPage, this.draftSearch);
      this.draftsArticles = res?.articles;
      this.draftsArticlesPagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
    },
    async fetchArticle(id) {
      this.article = {}
      const res = await ArticleAPI.fetchArticle(id);
      this.article = res.article;
      return res.article;
    },
    async createArticle(data) {
      const res = await ArticleAPI.createArticle(data);
      return res.article;
    },
    async updateArticle(id, data) {
      const res = await ArticleAPI.updateArticle(id, data);
      return res.article;
    },
    async deleteArticle(id) {
      const res = await ArticleAPI.deleteArticle(id);
      return res.article;
    },
    async articleRestore(id: number) {
      await ArticleAPI.articleRestore(id);
      await this.fetchTrashesArticles()
    },
    async articleDeletePermanently(id: number) {
      await ArticleAPI.articleDeletePermanently(id);
      await this.fetchTrashesArticles()
    },
    async resetArtcile() {
      this.article = {}
    }
  }
});
