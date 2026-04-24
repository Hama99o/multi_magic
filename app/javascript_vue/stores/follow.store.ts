import { defineStore } from 'pinia';
import FollowAPI from '@/apis/follow.api';

export const useFollowStore = defineStore({
  id: 'follow-store',
  state: () => ({
  }),
  getters: {},
  actions: {
    async createFollow(followed_id: number, data: {}) {
      const res = await FollowAPI.createFollow(followed_id, data);
      return res
    },
    async deleteFollow(id: number) {
      await FollowAPI.deleteFollow(id);
    }
  },
});
