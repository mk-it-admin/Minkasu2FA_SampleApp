import React, { Component } from 'react';
import { SafeAreaView, View, Button, StyleSheet, Platform } from 'react-native';
import { Minkasu2FAUIConstants, Minkasu2FAWebViewModule } from 'react-native-minkasu2fa-webview';

const MERCHANT_CUSTOMER_ID = "WebViewCustomerID";

export default class Home extends Component {

    static navigationOptions = {
    };

    state = {
        supportedMinkasu2FAOperationTypes: {}
    };

    async performMinkasu2FAOperation(opType) {
        try {
            if (Platform.OS == 'ios') {
                await Minkasu2FAWebViewModule.performMinkasu2FAOperation(MERCHANT_CUSTOMER_ID, opType, this.getiOSThemeObj());
            } else {
                await Minkasu2FAWebViewModule.performMinkasu2FAOperation(MERCHANT_CUSTOMER_ID, opType);
            }
            this.setState({ supportedMinkasu2FAOperationTypes: {} });
        }
        catch (e) {
            console.log(e.getMessage());
        }
    }

    showMinkasuMenu() {
        Minkasu2FAWebViewModule.getMinkasu2FAOperationTypes()
            .then((data) => {
                this.setState({ supportedMinkasu2FAOperationTypes: data });
            })
            .catch((err) => {
                console.log(err.getMessage());
            });
    }

    getiOSThemeObj = () => {
        return {
            [Minkasu2FAUIConstants.NAVIGATION_BAR_COLOR]: "#0433FF",
            [Minkasu2FAUIConstants.NAVIGATION_BAR_TEXT_COLOR]: "#FFFFFF",
            [Minkasu2FAUIConstants.BUTTON_BACKGROUND_COLOR]: "0433FF",
            [Minkasu2FAUIConstants.BUTTON_TEXT_COLOR]: "#FFFFFF",
            [Minkasu2FAUIConstants.DARK_MODE_NAVIGATION_BAR_COLOR]: "#942192",
            [Minkasu2FAUIConstants.DARK_MODE_NAVIGATION_BAR_TEXT_COLOR]: "#FFFFFF",
            [Minkasu2FAUIConstants.DARK_MODE_BUTTON_BACKGROUND_COLOR]: "#942192",
            [Minkasu2FAUIConstants.DARK_MODE_BUTTON_TEXT_COLOR]: "#FFFFFF",
            [Minkasu2FAUIConstants.SUPPORT_DARK_MODE]: true
        }
    }

    renderOperationTypes = (opTypes) => {
        let changePinBtn;
        if (opTypes[Minkasu2FAWebViewModule.CHANGE_PIN]) {
            changePinBtn = <Button title={opTypes[Minkasu2FAWebViewModule.CHANGE_PIN]} style={{ padding: 10 }}
                onPress={() => {
                    this.performMinkasu2FAOperation(opTypes[Minkasu2FAWebViewModule.CHANGE_PIN])
                }} />
        }
        let enableDisableBiometricBtn;
        if (opTypes[Minkasu2FAWebViewModule.ENABLE_BIOMETRIC]) {
            enableDisableBiometricBtn = <Button title={opTypes[Minkasu2FAWebViewModule.ENABLE_BIOMETRIC]} style={{ padding: 10 }}
                onPress={() => {
                    this.performMinkasu2FAOperation(opTypes[Minkasu2FAWebViewModule.ENABLE_BIOMETRIC]);
                }} />
        } else if (opTypes[Minkasu2FAWebViewModule.DISABLE_BIOMETRIC]) {
            enableDisableBiometricBtn = <Button title={opTypes[Minkasu2FAWebViewModule.DISABLE_BIOMETRIC]} style={{ padding: 10 }}
                onPress={() => {
                    this.performMinkasu2FAOperation(opTypes[Minkasu2FAWebViewModule.DISABLE_BIOMETRIC]);
                }} />
        }
        return <View style={{ flexDirection: "row", marginTop: 10, justifyContent: 'space-between' }}>
            {changePinBtn}
            {enableDisableBiometricBtn}
        </View>
    }

    createMinkasuConfigObj = () => {
        let customerInfo = {
            [Minkasu2FAUIConstants.CUSTOMER_FIRST_NAME]: "TestCustomer",
            [Minkasu2FAUIConstants.CUSTOMER_LAST_NAME]: "TestLastName",
            [Minkasu2FAUIConstants.CUSTOMER_EMAIL]: "test@minkasupay.com",
            [Minkasu2FAUIConstants.CUSTOMER_PHONE]: "+919876543210" // Format: +91XXXXXXXXXX (no spaces)
        };
        let addressInfo = {
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_LINE_1]: "123 Test Way",
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_LINE_2]: "Test Soc",
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_CITY]: "Mumbai",
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_STATE]: "Maharastra",// Unabbreviated e.g. Maharashtra (not MH)
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_COUNTRY]: "India",
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_ZIP_CODE]: "400068"// Format: XXXXXX (no spaces)
        };
        let orderInfo = {
            [Minkasu2FAUIConstants.CUSTOMER_ORDER_ID]: "Ord01_" + (Date.now().toString(36) + Math.random().toString(36).substr(2, 5)).toUpperCase()
        };
        let configObj = {
            [Minkasu2FAUIConstants.MERCHANT_ID]: "13579",
            [Minkasu2FAUIConstants.MERCHANT_TOKEN]: "789385aed6e4e3ff3e097f57dc58b4d8",
            //merchant_customer_id is a unique id associated with the currently logged in user.
            [Minkasu2FAUIConstants.CUSTOMER_ID]: MERCHANT_CUSTOMER_ID,
            [Minkasu2FAUIConstants.CUSTOMER_INFO]: customerInfo,
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_INFO]: addressInfo,
            [Minkasu2FAUIConstants.CUSTOMER_ORDER_INFO]: orderInfo,
            [Minkasu2FAUIConstants.SDK_MODE_SANDBOX]: true
        };
        if (Platform.OS === 'ios') {
            configObj[Minkasu2FAUIConstants.IOS_THEME_OBJ] = this.getiOSThemeObj();
        }
        return configObj;
    }

    payByAttribute = () => {
        this.props.navigation.navigate('Minkasu2FAAttributeFlow', { configObj: this.createMinkasuConfigObj(), initType: Minkasu2FAUIConstants.INIT_BY_ATTRIBUTE });
    };

    payByMethod = () => {
        this.props.navigation.navigate('Minkasu2FAMethodFlow', { configObj: this.createMinkasuConfigObj(), initType: Minkasu2FAUIConstants.INIT_BY_METHOD });
    };

    render() {
        return (
            <>
                <SafeAreaView style={styles.container}>
                    <View style={{ flexDirection: "row", justifyContent: 'space-between' }}>
                        <Button title="Pay By Attribute" style={{ padding: 10 }}
                            onPress={this.payByAttribute} />
                        <Button title="Pay By Method" style={{ padding: 10 }}
                            onPress={this.payByMethod} />
                    </View>
                    <View style={{ flexDirection: "row", justifyContent: 'space-between', marginTop: 10 }}>
                        <Button title="Show Minkasu Menu" style={{ padding: 10 }}
                            onPress={() => { this.showMinkasuMenu() }} />
                    </View>
                    <View style={{ height: 2, backgroundColor: '#000', marginTop: 10 }} />
                    {this.renderOperationTypes(this.state.supportedMinkasu2FAOperationTypes)}
                </SafeAreaView>
            </>);
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        flexDirection: "column",
        margin: 10,
        marginHorizontal: 16,
        marginVertical: 10
    }
});