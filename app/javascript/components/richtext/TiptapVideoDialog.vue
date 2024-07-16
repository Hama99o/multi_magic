<template>
  <v-dialog v-model="dialog" max-width="600px">
    <form @submit.prevent="onSubmit" class="bg-surface p-6">
      <div class="flex flex-col space-y-5">
        <InputContainer>
          <Label for="input-add-youtube-url">Tautan Youtube</Label>
          <Input
            type="url"
            id="input-add-youtube-url"
            v-model="inputYoutubeUrlRef"
            required
          />
        </InputContainer>
        <div class="flex flex-row justify-end space-x-3">
          <button
            type="button"
            class="rounded-md px-4 py-3 text-sm font-medium text-gray-600 hover:bg-gray-100"
            @click="closeDialog"
          >
            Batal
          </button>
          <button
            type="submit"
            class="rounded-md bg-blue-700 px-4 py-3 text-sm font-medium text-white hover:bg-opacity-80"
          >
            Tambah
          </button>
        </div>
      </div>
    </form>
  </v-dialog>
</template>

<script setup lang="ts">
import { ref } from "vue"
import InputContainer from "./InputContainer.vue"
import Input from "./Input.vue"
import Label from "./Label.vue"

const emit = defineEmits(["close", "insert"])

const inputYoutubeUrlRef = ref<string>("")
const dialog = ref(false)

function closeDialog() {
  emit("close")
}

function onSubmit() {
  emit("insert", inputYoutubeUrlRef.value)
  inputYoutubeUrlRef.value = ""
  closeDialog()
}

defineExpose({
  dialog
})
</script>
