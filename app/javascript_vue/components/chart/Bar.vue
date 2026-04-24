<template>
  <div class="bg-white rounded flex flex-col justify-center  items-center p-3 !h-[500px] !w-[500px]">
    <div class="flex ">
      <!-- Chart Type Selector -->
      <v-select
        :value="chartSelectOption"
        density="comfortable"
        :items="chartSelectOptions"
        class="p-2 !w-[300px] !h-[100px] "
        dense
        outlined
        @update:model-value="updateOption"
      />
    </div>

    <!-- Chart Component -->
    <Bar
      :options="chartOptions"
      :data="chartData"
    />
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Bar } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale } from 'chart.js'

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale)
const emit = defineEmits(['update-bar-chart-option']);

const props = defineProps({
  totalAmountLastYears: { type: Object, default: {} },
  chartSelectOption: { type: Object, default: 'months' }
});

// Define chart type options
const chartSelectOptions = ref(['months', 'years'])

const updateOption = (option) => {
  emit('update-bar-chart-option', option)
}

const chartData = ref({
  labels: props.totalAmountLastYears?.labels,
  datasets: [
    {
      label: `Total expenses over the last ${props.chartSelectOption}`,
      backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#FF6384', '#36A2EB', '#FFCE56', '#FF6384', '#36A2EB', '#FFCE56', '#FF6384', '#36A2EB', '#FFCE56'],
      borderWidth: 1,
      data: props.totalAmountLastYears?.data,
    },
  ],
})

const chartOptions = ref(true)

</script>