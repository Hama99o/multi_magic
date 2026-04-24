import { defineStore } from "pinia";

export const usePopUpStore = defineStore("pop-up", {
  state: () => ({
    data: {
      open: false,
      loading: false,
      event: null
    },
  }),
  actions: {
    update(args) {
      this.data = {
        ...this.data,
        ...args,
      };
    },
    openPopUp(opts) {
      const usePopUp = usePopUpStore();

      usePopUp.update({ open: true, ...opts });
    },
    closePopUp() {
      const usePopUp = usePopUpStore();

      usePopUp.update({ open: false, event: null, icon: null });
      try {
        this.data.close();
        this.data.customClass = '';
        this.data.title = '';
        this.data.subtitle = '';
        this.data.icon = '';
      }
      catch {
      }
    },
    confirmPopUp() {
      const usePopUp = usePopUpStore();
      usePopUp.update({ loading: true });
      this.data.confirm();
    },
    callback() {
      this.data.callback();
    },
  },
});
