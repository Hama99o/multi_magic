<template>
  <div
    :class="[
      disable ? disableVariantStyle[variant] : danger ? dangerVariantStyle[variant] : variantStyle[variant], iconBtnSize[buttonSize], circle ? '!rounded-full' : ''
    ]"
    class="select-none flex items-center justify-center cursor-pointer relative"
  >
    <slot name="default">
      <Icon
        :icon="icon"
        :class="iconSize[buttonSize]"
      />
    </slot>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { Icon } from "@iconify/vue";

const props = defineProps({
  variant: {
    type: String,
    default: 'default',
  },
  icon: {
    type: String,
    default: 'material-symbols:add'
  },
  buttonSize: {
    type: String,
    default: 'md'
  },
  disable: {
    type: Boolean,
    default: false
  },
  to: {
    type: String,
    default: null
  },
  danger: {
    type: Boolean,
    default: false
  },
  circle: {
    type: Boolean,
    default: false
  },
  colorClass: {
    type: String,
    default: ''
  }
})

const variantStyle = ref({
  default: `!rounded ${ props.colorClass ? props.colorClass : "!text-white !bg-primary hover:!bg-primary-hover active:!bg-primary-active"}`,
  outlined: `!rounded !border border-opacity-100 ${ props.colorClass ? props.colorClass : "!bg-white border-primary !text-primary hover:!bg-very-light-grey active:!bg-light-grey" }`,
  plain: `!rounded ${ props.colorClass ? props.colorClass : "!bg-transparent !text-primary hover:!bg-very-light-grey active:!bg-light-grey"}`,
  none: props.colorClass,
  noOutlined: `!rounded ${ props.colorClass ? props.colorClass : "!bg-transparent !text-dark-grey hover:!bg-very-light-grey hover:!text-primary active:!bg-light-grey"}`,
  hoverNoPrimary: `!rounded ${ props.colorClass ? props.colorClass : "!bg-transparent !text-dark-grey hover:!bg-very-light-grey active:!bg-light-grey"}`,
})

const disableVariantStyle = ref({
  default: "!cursor-default bg-background  !rounded !text-dark-grey",
  outlined: "!cursor-default !bg-white !border !rounded border-middle-grey !text-middle-grey",
  plain: "!cursor-default !bg-white !rounded !text-middle-grey",
  none: props.colorClass,
  noOutlined: "!rounded !text-middle-grey"
})

const dangerVariantStyle = ref({
  default: `!rounded !text-very-light-grey !bg-negative-red`,
  outlined: `!rounded !bg-white !border !border-opacity-100 !border-negative-red !text-negative-red`,
  plain: `!rounded !bg-transparent !text-negative-red`,
  none: props.colorClass,
  noOutlined: `!rounded !bg-transparent !text-negative-red`,
})

const iconBtnSize = ref({
  sm: `h-6 w-6 p-1`,
  md: `h-8 w-8 p-1`,
  lg: `h-10 w-10 p-2`,
  lg2: `h-12 w-12 p-2`,
  xl: `h-[50px] w-[50px] p-2`,
})

const iconSize = ref({
  sm: `h-4 w-4`,
  md: `h-6 w-6`,
  lg: `h-6 w-6`,
  lg2: `h-6 w-6`,
  xl: `h-6 w-6`,
})
</script>
