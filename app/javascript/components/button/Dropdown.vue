<template>
  <v-menu
    :offset="offset"
    :close-on-content-click="closeOnContentClick"
    transition="scale-transition"
    :max-width="300"
  >
    <template #activator="{ props }">
      <div v-bind="props">
        <slot name="activator">
          <v-btn
            class="text-none font-weight-regular"
            color="primary"
            variant="elevated"
            prepend-icon="mdi-menu-down"
          >
            Menu
          </v-btn>
        </slot>
      </div>
    </template>

    <v-card class="rounded-lg overflow-hidden">
      <v-list class="pa-0">
        <slot name="dropdown">
          <v-list-item
            v-for="(item, index) in items"
            :key="item?.id"
            :value="item"
            @click="item?.onClick"
            class="px-4 py-3 transition-colors duration-200 hover:bg-primary-lighten-1"
            :class="{ 'border-b border-gray-200': index !== items.length - 1 }"
          >
            <template #prepend>
              <v-icon
                :icon="item.icon || 'mdi-circle-small'"
                class="mr-3"
                color="primary"
              ></v-icon>
            </template>
            <v-list-item-title class="font-weight-medium">
              {{ item?.title }}
            </v-list-item-title>
          </v-list-item>
        </slot>
      </v-list>
    </v-card>
  </v-menu>
</template>

<script setup>

const props = defineProps({
  items: { type: Array, default: () => [] },
  closeOnContentClick: { type: Boolean, default: true },
  offset: { type: Number, default: 12 },
  bottom: { type: Boolean, default: false },
});

</script>