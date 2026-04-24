<template>
  <div
    class="relative flex flex-col justify-center p-6 items-center sm:min-w-[400px] sm:max-w-[800px] md:container md:mx-auto mt-3"
    :class="customClass"
  >
    <div
      :class="(icon && title) ? 'w-full flex flex-col text-center justify-center items-center' :
        'w-full flex flex-col text-center justify-center items-center mb-4'"
    >
      <slot name="header" />

      <div
        v-if="showClose"
        class="cursor-pointer absolute right-5 top-8"
        @click="closePopUp"
      >
        <icon
          icon="mdi-close"
          width="54"
          height="54"
          color="darkGrey"
        />
      </div>
    </div>

    <div
      v-if="icon"
      class="w-full flex flex-col justify-center items-center mb-4"
    >
      <v-icon
        :icon="icon"
        width="32"
        height="32"
        class="text-primary"
      />
    </div>

    <div
      class="w-full flex flex-col justify-center items-center mb-2"
    >
      <slot name="title">
        <p class="">
          {{ title }}
        </p>
      </slot>
    </div>

    <div
      class="w-full flex flex-col justify-center items-center text-darkGrey text-center normal-case text-sm"
      :class=" $slots.subtitle ? 'mb-8' : '' "
    >
      <slot name="subtitle" />
    </div>

    <div class="text-center w-full flex flex-col">
      <slot name="body" />
    </div>

    <div class="w-full flex flex-col">
      <slot name="buttons" />
    </div>
  </div>
</template>

<script setup>
import { Icon } from '@iconify/vue';
import { usePopUpStore } from "@/stores/pop-up.store";

const { closePopUp } = usePopUpStore();

const props = defineProps({
  icon: {
    type: String,
    default: ''
  },
  title: {
    type: String,
    default: ''
  },
  subtitle: {
    type: String,
    default: ''
  },
  customClass: {
    type: String,
    default: null
  },
  showClose: {
    type: Boolean,
    default: true
  }
  // close: {
  //   type: Boolean,
  //   default: false
  // }
})
</script>
