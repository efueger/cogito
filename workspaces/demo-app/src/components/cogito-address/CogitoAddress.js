import React from 'react'

import { WithStore } from '@react-frontend-developer/react-redux-render-prop'
import { Centered, ValueWrapper } from '@react-frontend-developer/react-layout-helpers'

export const CogitoAddress = () =>
  <WithStore
    selector={state => ({
      address: state.userData.account
    })}>
    {
      ({address}) =>
        <Centered>
          <p>Your Cogito account address is:</p>
          <ValueWrapper>{address || 'unknown'}</ValueWrapper>
        </Centered>
    }
  </WithStore>