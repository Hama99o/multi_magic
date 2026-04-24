import { Button, Spinner } from '@heroui/react'
import type { ComponentPropsWithRef, ReactNode } from 'react'
import type { ButtonRootProps } from '@heroui/react'

interface LoadingButtonProps extends ButtonRootProps {
  isLoading?: boolean
  children: ReactNode
}

export function LoadingButton({ isLoading, children, isDisabled, ...props }: LoadingButtonProps) {
  return (
    <Button isDisabled={isLoading || isDisabled} {...props}>
      {isLoading ? (
        <span className="flex items-center gap-2">
          <Spinner size="sm" />
          {children}
        </span>
      ) : (
        children
      )}
    </Button>
  )
}
