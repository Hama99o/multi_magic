import { defineStore } from 'pinia';
import UserAPI from '@/apis/user.api';

export const useUserStore = defineStore({
  id: 'user-store',
  state: () => ({
    isImpersonating: false,
    user: {},
    id: null,
    currentUser: null,
    users: [],
    global_users: [],
    search: '',
    loading: true,
    openChats: [],
    pagination: {},
    global_users_pagination: {},
    page: 1,
    theme: 'dark'
  }),
  getters: {},
  actions: {
    async fetchUsers() {
      this.loading = true;
      const res = await UserAPI.fetchUsers(this.page, this.search);
      this.users = res?.users;
      this.pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
    },
    async fetcGlobalhUsers(page = 1, search = '') {
      this.loading = true;
      const res = await UserAPI.fetcGlobalhUsers(page, search);
      this.global_users = res?.users;
      this.global_users_pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;

      return res?.users
    },
    async fetchFollowing(id: number, page = 1, search = '') {
      this.loading = true;
      const res = await UserAPI.fetchFollowing(id, page, search);
      return res?.users
      this.loading = false;
    },
    async fetchFollowers(id: number, page = 1, search = '') {
      this.loading = true;
      const res = await UserAPI.fetchFollowers(id, page, search);
      return res?.users
      this.loading = false;
    },
    async fetchUser(id: number) {
      await this.resetStates();
      const res = await UserAPI.fetchUser(id);
      this.user = res.user;
      this.loading = false;

    },
    async fetchCurrentUser(id: number) {
      await this.resetStates();
      const res = await UserAPI.fetchCurrentUser(id);
      localStorage.setItem('user', JSON.stringify(res.user));
      this.currentUser = res.user;
      this.id = res.user?.id;
      this.theme = res.user.theme || 'dark'
      this.isImpersonating = res.user.is_impersonating
    },
    async forgotPassword(email: string) {
      await UserAPI.forgotPassword(email)
    },
    async resetPassword(data: object) {
      await UserAPI.resetPassword(data)
    },
    async changePassword(id: number, data: {}) {
      await UserAPI.changePassword(id, data)
    },
    async deleteUserAvatar(id: number, image_name: 'photo') {
      const res = await UserAPI.deleteUserAvatar(id, image_name)

      if (Number(id) === Number(this.currentUser.id)) {
        this.currentUser = res.user;
        this.theme = res.user.theme || 'dark'
        localStorage.setItem('user', JSON.stringify(res.user));
      } else {
        this.user = res.user;
      }
      return res
    },
    async updateUser(id: number, data: {}) {
      const res = await UserAPI.updateUser(id, data);
      if ((Number(id) === Number(this.currentUser.id) && this.currentUser.id === res.user?.id)) {
        this.currentUser = res.user;
        this.theme = res.user.theme || 'dark'
        localStorage.setItem('user', JSON.stringify(res.user));
        if (this.user.id === this.currentUser.id && res.user.id === this.currentUser.id) {
          this.user = res.user;
        }
      } else if (this.user.id === res.user?.id) {
        this.user = res.user;
      }
      return res
    },
    async impersonateUser(id: number) {
      const res = await UserAPI.impersonateUser(id);
      this.user = res?.user;
    },
    async stopImpersonating() {
      const res = await UserAPI.stopImpersonating();
      this.user = res?.user;
    },
    async isSomeoneImpersonating() {
      const data = await UserAPI.isImpersonating()
      this.isImpersonating = data
    },
    async resetStates() {
      this.user = {};
      this.users = [];
      this.page = 1
      this.search = ''
      this.pagination = {};
      this.loading = true;
    },
  },
});
