<template>
  <NodeViewWrapper>
    <v-fade-transition origin="top center">
      <div class="relative flex flex-col" @mouseenter="showDialog" @mouseleave="handleMouseLeave">
        <div>
          <!-- Image Wrapper -->
          <div
            ref="imageWrapperRef"
            contenteditable="false"
            class="cover my-2 h-full w-full overflow-hidden rounded-[4px]"
          >
            <!-- Image Element -->
            <img
              :class="wrapperClassName"
              :style="{ width: imageWrapperWidth }"
              class="block py-0"
              :src="src"
              :alt="altText"
              @click="onClick"
            />
            <!-- Alt Text Edit Field with Buttons -->
            <div v-if="editor.isEditable && false" class="flex items-center justify-center">
              <div class="flex items-center justify-center !bg-surface" :class="wrapperClassName" :style="{ width: imageWrapperWidth }">
                <!-- Prepend Icon (Pencil) as a separate clickable button -->
                <v-icon v-if="editor.isEditable && !isEditingAlt" class="absolute ml-2 cursor-pointer" @click="enableAltEditing">
                  mdi-pencil
                </v-icon>

                <!-- Alt Text Field -->
                <v-text-field
                  v-model="altText"
                  class="pl-10 text-center pr-3"
                  :disabled="!isEditingAlt"
                  placeholder="Alt text"
                  variant="solo"
                  dense
                  hide-details
                  :append-icon="isEditingAlt ? 'mdi-check' : ''"
                  @click:append="saveAltText"
                ></v-text-field>
              </div>
            </div>
          </div>
        </div>

        <!-- Dialog with alignment options -->
        <div
          v-if="editor.isEditable"
          v-show="dialog"
          class="w-fit flex absolute top-0 left-1/2 -translate-x-1/2 items-center self-center rounded-[8px] gap-2 px-3 py-2 bg-surface cardShadow"
        >
          <!-- Alignment Controls -->
          <div
            class="flex cursor-pointer items-center justify-center rounded p-1 !text-dark-grey hover:bg-very-light-grey hover:!text-fake-black"
            :class="
              editor?.isActive('imageBlock', { align: 'left' })
                ? 'bg-very-light-grey !text-fake-black'
                : ''
            "
            @click="
              editor
                .chain()
                .focus(undefined, { scrollIntoView: false })
                .setImageBlockAlign('left')
                .run()
            "
          >
            <IconAlignLeft class="h-5 w-5" />
          </div>

          <div
            class="flex cursor-pointer items-center justify-center rounded p-1 !text-dark-grey hover:bg-very-light-grey hover:!text-fake-black"
            :class="
              editor?.isActive('imageBlock', { align: 'center' })
                ? 'bg-very-light-grey !text-fake-black'
                : ''
            "
            @click="
              editor
                .chain()
                .focus(undefined, { scrollIntoView: false })
                .setImageBlockAlign('center')
                .run()
            "
          >
            <IconAlignCenter class="h-5 w-5" />
          </div>

          <div
            class="flex cursor-pointer items-center justify-center rounded p-1 !text-dark-grey hover:bg-very-light-grey hover:!text-fake-black"
            :class="
              editor?.isActive('imageBlock', { align: 'right' })
                ? 'bg-very-light-grey !text-fake-black'
                : ''
            "
            @click="
              editor
                .chain()
                .focus(undefined, { scrollIntoView: false })
                .setImageBlockAlign('right')
                .run()
            "
          >
            <IconAlignRight class="h-5 w-5" />
          </div>

          <div class="mx-1" />

          <!-- Image width control -->
          <ImageBlockWidth
            :width="imageWrapperWidth"
            @handle-change="
              editor
                .chain()
                .focus(undefined, { scrollIntoView: false })
                .setImageBlockWidth($event)
                .run()
            "
          />
        </div>
      </div>
    </v-fade-transition>
  </NodeViewWrapper>
</template>

<script setup>
import { ref, computed, watch } from 'vue';
import { nodeViewProps, NodeViewWrapper } from '@tiptap/vue-3';
import { debounce } from 'lodash';
import { IconAlignCenter, IconAlignRight, IconAlignLeft } from '@tabler/icons-vue';
import ImageBlockWidth from './ImageBlockWidth.vue';

// Props and data
const props = defineProps(nodeViewProps);
const { src, alt } = props.node.attrs;

const dialog = ref(false);
const imageWrapperRef = ref(props.node.attrs.align);
const imageWrapperWidth = ref(props.node.attrs.width || 100);
const imageWrapperAlign = ref('center');
const altText = ref(alt || '');

// Toggle whether the alt text field is editable
const isEditingAlt = ref(false);

// Debounce the hideDialog function to wait 3 seconds after the last mouse leave event
const hideDialog = debounce(() => {
  dialog.value = false;
}, 500); // 0.5 second delay

const wrapperClassName = computed(() => {
  const align = imageWrapperAlign.value;

  switch (align) {
    case 'left':
      return 'ml-0 mr-auto';
    case 'center':
      return 'mx-auto';
    case 'right':
      return 'ml-auto mr-0';
    default:
      return 'mx-auto';
  }
});

// Show dialog on hover and cancel any hide timeout
const showDialog = () => {
  dialog.value = true;
  hideDialog.cancel(); // Cancel the debounced function
};

// Hide dialog after a delay
const handleMouseLeave = () => {
  hideDialog();
};

// Enable alt text editing when user clicks the prepend icon
const enableAltEditing = () => {
  isEditingAlt.value = true;
};

// Save the alt text when user clicks the append icon
const saveAltText = () => {
  isEditingAlt.value = false;
  props.editor
    .chain()
    .focus(undefined, { scrollIntoView: false })
    .setImageBlockAlt({ src, alt: altText.value })
    .run();
};

// Watch for prop changes to adjust image properties
watch(props, (newValue) => {
  if (newValue.node) {
    imageWrapperWidth.value = props.node.attrs.width;
    imageWrapperAlign.value = props.node.attrs.align;
    altText.value = props.node.attrs.alt || ''; // Update alt text
  }
});
</script>

<style lang="scss">
.cardShadow {
  box-shadow: 0px 8px 10px rgba(0, 0, 0, 0.14), 0px 3px 14px rgba(0, 0, 0, 0.12),
    0px 5px 5px rgba(0, 0, 0, 0.2);
}
</style>
