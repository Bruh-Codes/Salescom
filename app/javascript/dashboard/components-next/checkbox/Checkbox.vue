<script setup>
defineProps({
  indeterminate: {
    type: Boolean,
    default: false,
  },
  disabled: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['change']);

const modelValue = defineModel('modelValue', {
  type: Boolean,
  default: false,
});

const handleChange = event => {
  modelValue.value = event.target.checked;
  emit('change', event);
};
</script>

<template>
  <div class="relative w-4 h-4">
    <input
      :checked="modelValue"
      :indeterminate="indeterminate"
      type="checkbox"
      :disabled="disabled"
      class="peer absolute inset-0 z-10 h-4 w-4 disabled:pointer-events-none disabled:opacity-50 appearance-none rounded border border-n-input ring-transparent transition-colors duration-200 checked:border-n-primary checked:bg-n-primary indeterminate:border-n-primary indeterminate:bg-n-primary hover:enabled:border-n-ring focus-visible:outline focus-visible:outline-2 focus-visible:outline-n-ring focus-visible:outline-offset-2 cursor-pointer"
      @change="handleChange"
    />
    <!-- Checkmark SVG -->
    <svg
      viewBox="0 0 14 14"
      fill="none"
      class="pointer-events-none absolute w-3.5 h-3.5 z-20 stroke-white opacity-0 peer-checked:opacity-100 transition-opacity duration-200 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2"
    >
      <path
        d="M3 8L6 11L11 3.5"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    </svg>
    <!-- Minus/Indeterminate SVG -->
    <svg
      viewBox="0 0 14 14"
      fill="none"
      class="pointer-events-none absolute w-3.5 h-3.5 z-20 stroke-white opacity-0 peer-indeterminate:opacity-100 transition-opacity duration-200 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2"
    >
      <path
        d="M3 7L11 7"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    </svg>
  </div>
</template>
