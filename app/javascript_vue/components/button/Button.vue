<template>
  <div
    :class="[
      disable ? disableVariantStyle[variant] : danger ? dangerVariantStyle[variant] : variantStyle[variant], block ? 'w-full' : 'w-fit',
    ]"
    class="select-none flex gap-2 px-4 items-center justify-center min-w-[88px] h-10 cursor-pointer relative"
    @click="click"
  >
    <slot name="prepend">
      <div>
        <Icon
          v-if="prependIcon"
          :icon="prependIcon"
          :class="prependClass"
        />
      </div>
    </slot>

    <slot>
      <div class="py-2.5 text-xs"
      :class="loading ? 'text-transparent' : null">
        <slot name="button-text">
          <p class="font-medium text-xs whitespace-nowrap">
            {{ text }}
          </p>
        </slot>
      </div>
    </slot>

    <slot name="append">
      <div>
        <Icon
          v-if="appendIcon"
          :icon="appendIcon"
        />
      </div>
    </slot>

    <div
      v-if="loading"
      class="absolute w-full h-full flex items-center justify-center overflow-hidden rounded"
      :class="[danger ? dangerLoadingVariantStyle[variant] : loadingVariantStyle[variant]]"
    >
      <slot name="loader">
        <btn-loader />
      </slot>
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { Icon } from "@iconify/vue";
import btnLoader from "@/components/animation/Loader.vue";

const emit = defineEmits(['click'])

const props = defineProps({
  variant: {
    type: String,
    default: 'default',
  },
  prependIcon: {
    type: String,
    default: ''
  },
  prependClass: {
    type: String,
    default: ''
  },
  appendIcon: {
    type: String,
    default: ''
  },
  text: {
    type: String,
    default: 'button'
  },
  disable: {
    type: Boolean,
    default: false
  },
  to: {
    type: String,
    default: null
  },
  loading: {
    type: Boolean,
    default: false
  },
  danger: {
    type: Boolean,
    default: false
  },
  colorClass: {
    type: String,
    default: ''
  },
  loadingColorClass: {
    type: String,
    default: ''
  },
  block: {
    type: Boolean,
    default: false
  }
})

const variantStyle = ref({
  default: `!rounded ${props.colorClass ? props.colorClass : "!text-white !bg-primary hover:!bg-primary-hover active:!bg-primary-active"}`,
  outlined: `!rounded !border !border-opacity-100 !bg-white hover:!bg-very-light-grey active:!bg-light-grey ${ props.colorClass ? props.colorClass : "!border-primary !text-primary"}`,
  plain: `!rounded !bg-transparent hover:!bg-very-light-grey active:!bg-light-grey ${ props.colorClass ? props.colorClass : "!text-primary"}`,
  none: props.colorClass,
  neutral: `!rounded ${ props.colorClass ? props.colorClass : "!bg-transparent !!text-fake-black hover:!bg-very-light-grey active:!bg-light-grey"}`,
})

const disableVariantStyle = ref({
  default: "!cursor-default !bg-middle-grey !rounded !text-dark-grey !rounded",
  outlined: "!cursor-default !bg-white !border !border-middle-grey !text-middle-grey !rounded",
  plain: "!cursor-default !bg-white !text-middle-grey !rounded",
  none: props.colorClass,
  neutral: "!cursor-default !rounded !text-fake-black"
})

const dangerVariantStyle = ref({
  default: "!rounded !text-very-light-grey !bg-negative-red",
  outlined: "!rounded !bg-white !border !border-opacity-100 !border-negative-red !text-negative-red hover:!bg-very-light-grey active:!bg-light-grey",
  plain: "!rounded !bg-transparent !text-negative-red hover:!bg-very-light-grey active:!bg-light-grey",
  none: props.colorClass,
  neutral: `!rounded !bg-transparent !text-negative-red hover:!bg-very-light-grey active:!bg-light-grey`,
})

const loadingVariantStyle = ref({
  default: `!cursor-default !rounded !text-very-light-grey ${ props.loadingColorClass ? props.loadingColorClass : '!bg-primary-hover' }`,
  outlined: `!cursor-default !rounded !bg-very-light-grey ${ props.loadingColorClass ? props.loadingColorClass : '!text-primary' }`,
  plain: `!cursor-default !rounded !bg-very-light-grey ${ props.loadingColorClass ? props.loadingColorClass : '!text-primary' }`,
  none: props.colorClass,
  neutral: `!cursor-default !rounded ${ props.colorClass ? props.colorClass : "!bg-transparent !text-primary"}`,
})

const dangerLoadingVariantStyle = ref({
  default: "!cursor-default !text-very-light-grey !bg-negative-red",
  outlined: "!cursor-default !text-negative-red !bg-very-light-grey",
  plain: "!cursor-default !bg-very-light-grey !text-negative-red",
  none: props.colorClass,
  neutral: `!rounded !bg-transparent !text-negative-red hover:!bg-very-light-grey active:!bg-light-grey`,
})

const click = () => {
  if (!props.disable) {
    emit('click')
  }
}
</script>

@/components/animation/Loader.vue