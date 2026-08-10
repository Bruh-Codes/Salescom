<script setup>
import { useI18n } from 'vue-i18n';

const emit = defineEmits(['change']);

const { t } = useI18n();

const modelValue = defineModel({
  type: Boolean,
  default: false,
});

const updateValue = () => {
  modelValue.value = !modelValue.value;
  emit('change', !modelValue.value);
};
</script>

<template>
  <button
    type="button"
    class="group relative h-5 rounded-full w-9 flex-shrink-0 select-none focus-visible:outline focus-visible:outline-2 focus-visible:outline-n-ring focus-visible:outline-offset-2 transition-colors duration-200 disabled:pointer-events-none disabled:opacity-50"
    :class="modelValue ? 'bg-n-primary' : 'bg-n-input'"
    role="switch"
    :aria-checked="modelValue"
    @click="updateValue"
  >
    <span class="sr-only">{{ t('SWITCH.TOGGLE') }}</span>
    <span
      class="absolute top-1/2 ltr:left-0.5 rtl:right-0.5 -translate-y-1/2 transition-transform duration-200"
      :class="
        modelValue
          ? 'ltr:translate-x-4 rtl:-translate-x-4'
          : 'ltr:translate-x-0 rtl:translate-x-0'
      "
    >
      <span class="block h-4 w-4 rounded-full bg-white shadow-sm" />
    </span>
  </button>
</template>
