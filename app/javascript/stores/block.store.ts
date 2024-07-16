import { defineStore } from 'pinia';
import BlockAPI from '@/apis/block.api';

export const useBlockStore = defineStore({
  id: 'block-store',
  state: () => ({
  }),
  getters: {},
  actions: {
    async createBlock(block_id: number) {
      const res = await BlockAPI.createBlock(block_id);
      return res
    },
    async deleteBlock(id: number) {
      await BlockAPI.deleteBlock(id);
    }
  },
});
