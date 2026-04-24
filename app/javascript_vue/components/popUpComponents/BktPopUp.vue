<template>
  <!--    INFO: GENERIC MODAL-->
  <v-card class="!rounded-xl !shadow">
    <component
      :is="data.componentName"
      v-bind="data"
    />
  </v-card>
</template>

<script>
import { storeToRefs } from "pinia";
import { usePopUpStore } from "@/stores/pop-up.store";
import PopUpSkeleton from "./PopUpSkeleton.vue";
import PopUpValidation from "./PopUpValidation.vue";
import PopUpShareUserConfig from "./PopUpShareUserConfig.vue";

export default {
  components: {
    PopUpSkeleton,
    PopUpValidation,
    PopUpShareUserConfig
  },
  setup() {
    const { data } = storeToRefs(usePopUpStore());

    return {
      data,
    };
  },
};
</script>
