<template>
  <v-dialog v-model="dialog" max-width="600px">
    <form @submit.prevent="update" class="bg-surface p-6">
      <div class="flex flex-col space-y-5">
        <InputContainer>
          <Label for="input-link-url">Tautan</Label>
          <Input type="url" id="input-link-url" v-model="inputLinkRef" />
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
            Simpan
          </button>
        </div>
      </div>
    </form>
  </v-dialog>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from "vue"
import Label from "./Label.vue"
import Input from "./Input.vue"
import InputContainer from "./InputContainer.vue"

const props = defineProps<{ show: boolean; currentUrl?: string }>()
const emit = defineEmits(["close", "update"])
const inputLinkRef = ref<string>()
const dialog = ref(false)

function closeDialog() {
  emit("close")
}

function update() {
  emit("update", inputLinkRef.value)
  emit("close")
}

onMounted(() => {
  inputLinkRef.value = props.currentUrl ?? ""
})

defineExpose({
  dialog
})

watch(
  () => props.currentUrl,
  () => {
    inputLinkRef.value = props.currentUrl ?? ""
  }
)

</script>
