import { defineStore } from "pinia";
import { createConsumer } from "@rails/actioncable";

export const useActionCable = defineStore({
  id: "action-cable",
  state: () => ({
    cable: null,
  }),
  getters: {},
  actions: {
    initActionCable() {
      const userParams = JSON.parse(window.localStorage.getItem("user"));
      const tokenParams = window.localStorage.getItem("token");

      if (userParams && tokenParams && !this.cable) {
        this.cable = createConsumer(
          `${import.meta.env.VITE_MULTI_MAGIC_WEBSOCKET_DOMAIN}?token=${
            tokenParams
          }&email=${userParams["email"]}`
        );
      }
    },
  },
});
