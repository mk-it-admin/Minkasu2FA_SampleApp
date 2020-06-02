/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */
import React, { Component } from 'react';
import { } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

import HomeActivity from './components/HomeActivity';
import Minkasu2FAAttributeFlowComponent from './components/Minkasu2FAAttributeFlowComponent';
import Minkasu2FAMethodFlowComponent from './components/Minkasu2FAMethodFlowComponent';

const Stack = createStackNavigator();

export default class App extends Component {
  render() {
    return (
      <NavigationContainer>
        <Stack.Navigator initialRouteName="Home" screenOptions={{
          headerStyle: {
            backgroundColor: '#03A9F4',
          },
          headerTintColor: '#fff',
          headerTitleStyle: {
            fontWeight: 'bold',
          }
        }}>
          <Stack.Screen name="Home" component={HomeActivity} options={{ title: "HOME" }} />
          <Stack.Screen name="Minkasu2FAAttributeFlow" component={Minkasu2FAAttributeFlowComponent} />
          <Stack.Screen name="Minkasu2FAMethodFlow" component={Minkasu2FAMethodFlowComponent} />
        </Stack.Navigator>
      </NavigationContainer>
    );
  };
}