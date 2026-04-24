<template>
  <!-- Edit Avatar Dialog -->
  <v-dialog v-model="dialog" max-width="500px" @click:outside="closeDialog">
    <v-card class="rounded-lg shadow-lg overflow-hidden">
      <v-card-actions>
        <v-btn @click="closeDialog" icon="mdi mdi-window-close"></v-btn>
      </v-card-actions>

      <!-- Add overflow-auto class for scrolling -->
      <v-card-text class="px-6 mt-0 overflow-auto max-h-[80vh]">
        <div class="flex justify-between mb-2" v-if="previewPhoto">
          <div class="bg-black/40 flex items-center justify-center h-[32px] w-[32px] cursor-pointer transition-colors duration-500 hover:bg-[rgb(228,111,111)]" title="Flip Horizontal" @click="flip(true, false)">
            <span class="mdi mdi-flip-horizontal"></span>
          </div>
          <div class="bg-black/40 flex items-center justify-center h-[32px] w-[32px] cursor-pointer transition-colors duration-500 hover:bg-[rgb(228,111,111)]" title="Flip Vertical" @click="flip(false, true)">
            <span class="mdi mdi-flip-vertical"></span>
          </div>
          <div class="bg-black/40 flex items-center justify-center h-[32px] w-[32px] cursor-pointer transition-colors duration-500 hover:bg-[rgb(228,111,111)]" title="Rotate Clockwise" @click="rotate(90)">
            <span class="mdi mdi-reload"></span>
          </div>
          <div class="bg-black/40 flex items-center justify-center h-[32px] w-[32px] cursor-pointer transition-colors duration-500 hover:bg-[rgb(228,111,111)]" title="Rotate Counter-Clockwise" @click="rotate(-90)">
            <span class="mdi mdi-restore"></span>
          </div>
          <div class="bg-black/40 flex items-center justify-center h-[32px] w-[32px] cursor-pointer transition-colors duration-500 hover:bg-[rgb(228,111,111)]" title="Maximize" @click="maximize()">
            <span class="mdi mdi-overscan"></span>
          </div>
          <div class="bg-black/40 flex items-center justify-center h-[32px] w-[32px] cursor-pointer transition-colors duration-500 hover:bg-[rgb(228,111,111)]" title="Resize (x2)" @click="resize(2, 2)">
            <span class="mdi mdi-magnify-minus"></span>
          </div>
          <div class="bg-black/40 flex items-center justify-center h-[32px] w-[32px] cursor-pointer transition-colors duration-500 hover:bg-[rgb(228,111,111)]" title="Resize (x1/2)" @click="resize(0.5, 0.5)">
            <span class="mdi mdi-magnify-plus"></span>
          </div>
          <div class="bg-black/40 flex items-center justify-center h-[32px] w-[32px] cursor-pointer transition-colors duration-500 hover:bg-[rgb(228,111,111)]" title="Download" @click="download()">
            <span class="mdi mdi-download-box-outline"></span>
          </div>
        </div>

        <cropper
          v-if="previewPhoto"
          ref="cropperRef"
          class="cropper max-h-[10vh] sm:max-h-[10vh] md:max-h-[10vh] lg:max-h-[10vh] w-full"
          :src="previewPhoto"
          :transitions="true"
          image-restriction="fit-area"
          :default-size="{
            width: 1024,
            height: 1024,
          }"
        />

        <v-file-input
          v-model="selectedImage"
          accept="image/*"
          show-size
          truncate-length="20"
          label="Drag & Drop or Click to Upload"
          outlined
          dense
          class="mb-4 rounded-lg truncate mt-2"
          @change="handleImageChange"
        ></v-file-input>

        <v-card-actions class="justify-center space-x-4">
          <v-btn
            color="primary"
            class="rounded-lg py-3 px-6 text-white bg-blue-500 hover:bg-blue-600 transition-colors duration-200"
            @click="uploadImage"
            :disabled="!previewPhoto"
          >
            Upload Image
          </v-btn>

          <v-btn
            color="error"
            :disabled="!image"
            class="rounded-lg py-3 px-6 bg-red-500 text-white hover:bg-red-600 disabled:bg-gray-300 transition-colors duration-200"
            @click="deleteAvatar"
          >
            Delete Photo
          </v-btn>
        </v-card-actions>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref, watch, computed } from 'vue';
import { storeToRefs } from 'pinia';
import { useMobileStore } from "@/stores/mobile";
import { Cropper } from "vue-advanced-cropper";
import "vue-advanced-cropper/dist/style.css";
const { isMobile } = storeToRefs(useMobileStore());
import 'vue-advanced-cropper/dist/theme.bubble.css';

const emits = defineEmits(['upload-image', 'delete-photo'])


const props = defineProps({
  image: { type: String, default: null },
  imageType: { type: String, default: 'photo' },
});

const dialog = ref(false)
const selectedImage = ref(null);
const cropperRef = ref(null);
const previewPhoto = ref(props.image);

// onMounted(async () => {
//   try {
//     previewPhoto.value = props.image
//   } catch (error) {
//     console.log(error);
//   }
// });

const uploadImage = async () => {
  cropImage()
  if (selectedImage.value) {
    try {
      const formData = new FormData();

      // Append the image file to the FormData object
      formData.append(props.imageType, selectedImage.value);
      // Make the API request to update the user
      emits('upload-image', formData, previewPhoto.value, props.imageType)

      closeDialog();
    } catch (error) {
      console.log('Upload failed:', error);
    }
  }
};

const flip = (x, y) => {
    const { image } = cropperRef.value.getResult();
    if (image.transforms.rotate % 180 !== 0) {
      cropperRef.value.flip(!x, !y);
    } else {
      cropperRef.value.flip(x, y);
    }
  }
const cropImage = () => {
  if (cropperRef.value) {
    const { canvas } = cropperRef.value.getResult();
    if (canvas) {
      // Use canvas.toDataURL() without specifying type
      previewPhoto.value = canvas.toDataURL()
      selectedImage.value = dataURLtoFile(previewPhoto.value, 'cropped_image.png'); // Convert to Blob
      maximize()
    }
  }
};

const maximize = () => {
  if (!cropperRef.value) return null
  const center = {
    left: cropperRef.value.coordinates.left + cropperRef.value.coordinates.width / 2,
    top: cropperRef.value.coordinates.top + cropperRef.value.coordinates.height / 2,
  };

  cropperRef.value.setCoordinates([
    ({ coordinates, imageSize }) => ({
      width: imageSize.width,
      height: imageSize.height,
    }),
    ({ coordinates, imageSize }) => ({
      left: center.left - coordinates.width / 2,
      top: center.top - coordinates.height / 2,
    }),
  ]);
}

// Convert base64 to Blob
const dataURLtoFile = (dataUrl, filename) => {
  const arr = dataUrl.split(',');
  const mime = arr[0].match(/:(.*?);/)[1];
  const bstr = atob(arr[1]);
  let n = bstr.length;
  const u8arr = new Uint8Array(n);
  while (n--) {
    u8arr[n] = bstr.charCodeAt(n);
  }
  return new File([u8arr], filename, { type: mime });
};

const deleteAvatar = () => {
  emits('delete-avatar')
  dialog.value = false
  selectedImage.value = null
  previewPhoto.value = null
};

const handleImageChange = async() => {
  if (selectedImage.value) {
    const reader = new FileReader();
    reader.onload = (e) => {
      previewPhoto.value = e.target.result

    };
    reader.readAsDataURL(selectedImage.value);
    // maximize()
  }
};

const closeDialog = () => {
  dialog.value = false
  selectedImage.value = null
  previewPhoto.value = null
};

const rotate = (angle) =>  {
  cropperRef.value.rotate(angle);
}
const download = () =>  {
  const result = cropperRef.value.getResult().canvas.toDataURL();
  const newTab = window.open();
  newTab.document.body.innerHTML = `<img src="${result}"></img>`;
}

const resize = (width = 1, height = 1) => {
  let startCoordinates;
  cropperRef.value.setCoordinates([
    ({ coordinates, imageSize }) => {
      startCoordinates = coordinates;
      return {
        width: coordinates.width * width,
        height: coordinates.height * height,
      };
    },
    ({ coordinates, imageSize }) => ({
      left: startCoordinates.left + (startCoordinates.width - coordinates.width) / 2,
      top: startCoordinates.top + (startCoordinates.height - coordinates.height) / 2,
    })
  ]);
}

defineExpose({
  dialog
})
</script>
