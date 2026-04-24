import { TextField, Label, Input, FieldError } from '@heroui/react'
import type { ReactNode, ComponentPropsWithRef } from 'react'
import type { TextFieldRootProps } from '@heroui/react'

interface FormFieldProps extends Omit<TextFieldRootProps, 'children'> {
  label: string
  placeholder?: string
  type?: string
  errorMessage?: string | false | null
  endContent?: ReactNode
  autoComplete?: string
  inputRef?: ComponentPropsWithRef<typeof Input>['ref']
  inputProps?: Omit<ComponentPropsWithRef<typeof Input>, 'ref'>
}

export function FormField({
  label,
  errorMessage,
  endContent,
  autoComplete,
  type = 'text',
  inputRef,
  inputProps,
  ...fieldProps
}: FormFieldProps) {
  return (
    <TextField
      isInvalid={!!errorMessage}
      {...fieldProps}
      className={`flex flex-col gap-1 ${fieldProps.fullWidth ? 'w-full' : ''} ${fieldProps.className ?? ''}`}
    >
      <Label className="text-sm font-medium text-foreground">{label}</Label>
      <div className="relative flex items-center">
        <Input
          type={type}
          autoComplete={autoComplete}
          ref={inputRef}
          className={`w-full rounded-lg border px-3 py-2 text-sm outline-none transition
            bg-background text-foreground
            border-border placeholder:text-foreground-400
            focus:border-primary focus:ring-2 focus:ring-primary/20
            data-[invalid]:border-danger data-[invalid]:ring-danger/20
            ${endContent ? 'pr-10' : ''}
            ${inputProps?.className ?? ''}`}
          {...inputProps}
        />
        {endContent && (
          <div className="absolute right-3 flex items-center">{endContent}</div>
        )}
      </div>
      <FieldError className="text-xs text-danger">{errorMessage || null}</FieldError>
    </TextField>
  )
}
