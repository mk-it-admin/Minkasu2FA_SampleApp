import React, { Component } from 'react';
import { SafeAreaView, View, Text, Button, StyleSheet, Platform } from 'react-native';
import { WebView } from 'react-native-webview';
import { Picker, PickerIOS } from '@react-native-picker/picker';
const MERCHANT_CUSTOMER_ID = "WebViewCustomerID";
const NET_BANKING_TYPE = 1;
const CARD_TYPE = 2;

const Minkasu2FA = WebView.Minkasu2FA;
let Minkasu2FAConstants = Minkasu2FA.Constants;

export default class Home extends Component {

    static navigationOptions = {
    };

    state = {
        availableMinkasu2FAOperationTypes: {},
        paymentType: NET_BANKING_TYPE
    };

    constructor(props) {
        super(props);
    }

    async performMinkasu2FAOperation(opType) {
        try {
            if (Platform.OS == 'ios') {
                await Minkasu2FA.performMinkasu2FAOperation(MERCHANT_CUSTOMER_ID, opType, this.getiOSThemeObj());
            } else {
                await Minkasu2FA.performMinkasu2FAOperation(MERCHANT_CUSTOMER_ID, opType, null);
            }
            this.setState({ availableMinkasu2FAOperationTypes: {} });
        }
        catch (e) {
            console.log(e.getMessage());
        }
    }

    showMinkasuMenu() {
        Minkasu2FA.getAvailableMinkasu2FAOperations()
            .then((data) => {
                this.setState({ availableMinkasu2FAOperationTypes: data });
            })
            .catch((err) => {
                console.log(err.getMessage());
            });
    }

    getiOSThemeObj = () => {
        return {
            [Minkasu2FAConstants.NAVIGATION_BAR_COLOR]: "#0433FF",
            [Minkasu2FAConstants.NAVIGATION_BAR_TEXT_COLOR]: "#FFFFFF",
            [Minkasu2FAConstants.DARK_MODE_NAVIGATION_BAR_COLOR]: "#942192",
            [Minkasu2FAConstants.DARK_MODE_NAVIGATION_BAR_TEXT_COLOR]: "#FFFFFF",
            [Minkasu2FAConstants.SUPPORT_DARK_MODE]: true
        }
    }

    renderOperationTypes = (opTypes) => {
        let changePinBtn;
        if (opTypes[Minkasu2FAConstants.CHANGE_PIN]) {
            changePinBtn = <Button title={opTypes[Minkasu2FAConstants.CHANGE_PIN]} style={{ padding: 10 }}
                onPress={() => {
                    this.performMinkasu2FAOperation(opTypes[Minkasu2FAConstants.CHANGE_PIN])
                }} />
        }
        let enableDisableBiometricBtn;
        if (opTypes[Minkasu2FAConstants.ENABLE_BIOMETRICS]) {
            enableDisableBiometricBtn = <Button title={opTypes[Minkasu2FAConstants.ENABLE_BIOMETRICS]} style={{ padding: 10 }}
                onPress={() => {
                    this.performMinkasu2FAOperation(opTypes[Minkasu2FAConstants.ENABLE_BIOMETRICS]);
                }} />
        } else if (opTypes[Minkasu2FAConstants.DISABLE_BIOMETRICS]) {
            enableDisableBiometricBtn = <Button title={opTypes[Minkasu2FAConstants.DISABLE_BIOMETRICS]} style={{ padding: 10 }}
                onPress={() => {
                    this.performMinkasu2FAOperation(opTypes[Minkasu2FAConstants.DISABLE_BIOMETRICS]);
                }} />
        }
        return <View style={{ flexDirection: "row", marginTop: 10, justifyContent: 'space-between' }}>
            {changePinBtn}
            {enableDisableBiometricBtn}
        </View>
    }

    createMinkasuConfigObj = () => {
        let customerInfo = {
            [Minkasu2FAConstants.CUSTOMER_FIRST_NAME]: "TestFirstName",
            [Minkasu2FAConstants.CUSTOMER_LAST_NAME]: "TestLastName",
            [Minkasu2FAConstants.CUSTOMER_EMAIL]: "test@xyz.com",
            [Minkasu2FAConstants.CUSTOMER_PHONE]: "+919876543210" // Format: +91XXXXXXXXXX (no spaces)
        };
        let addressInfo = {
            [Minkasu2FAConstants.CUSTOMER_ADDRESS_LINE_1]: "123 Test Way",
            [Minkasu2FAConstants.CUSTOMER_ADDRESS_LINE_2]: "Test Apartments",
            [Minkasu2FAConstants.CUSTOMER_ADDRESS_CITY]: "Mumbai",
            [Minkasu2FAConstants.CUSTOMER_ADDRESS_STATE]: "Maharastra",// Unabbreviated e.g. Maharashtra (not MH)
            [Minkasu2FAConstants.CUSTOMER_ADDRESS_COUNTRY]: "India",
            [Minkasu2FAConstants.CUSTOMER_ADDRESS_ZIP_CODE]: "400068"// Format: XXXXXX (no spaces)
        };
        /* let orderDetails = {
            "key1": "val1",
            "key2": "val2",
            "key3": "val3"
        }; */
        let orderInfo = {
            [Minkasu2FAConstants.CUSTOMER_ORDER_ID]: "Ord01_" + (Date.now().toString(36) + Math.random().toString(36).substr(2, 5)).toUpperCase() // The order id is used to later identify
            //[Minkasu2FAConstants.CUSTOMER_BILLING_CATEGORY]: "FLIGHT",
            //[Minkasu2FAConstants.CUSTOMER_CUSTOM_DATA]: JSON.stringify(orderDetails),

        };
        let configObj = {
            [Minkasu2FAConstants.MERCHANT_ID]: "13579",
            [Minkasu2FAConstants.MERCHANT_TOKEN]: "789385aed6e4e3ff3e097f57dc58b4d8",
            //merchant_customer_id is a unique id associated with the currently logged in user.
            [Minkasu2FAConstants.CUSTOMER_ID]: MERCHANT_CUSTOMER_ID,
            [Minkasu2FAConstants.CUSTOMER_INFO]: customerInfo,
            [Minkasu2FAConstants.CUSTOMER_ADDRESS_INFO]: addressInfo,
            [Minkasu2FAConstants.CUSTOMER_ORDER_INFO]: orderInfo,
            [Minkasu2FAConstants.SDK_MODE_SANDBOX]: true
        };
        if (Platform.OS === 'ios') {
            configObj[Minkasu2FAConstants.IOS_THEME_OBJ] = this.getiOSThemeObj();
        }
        return configObj;
    }

    payByAttribute = () => {
        this.props.navigation.navigate('Minkasu2FAAttributeFlow', { configObj: this.createMinkasuConfigObj(), initType: Minkasu2FAConstants.INIT_BY_ATTRIBUTE, isCardEnabled: this.state.paymentType == CARD_TYPE });
    };

    payByMethod = () => {
        this.props.navigation.navigate('Minkasu2FAMethodFlow', { configObj: this.createMinkasuConfigObj(), initType: Minkasu2FAConstants.INIT_BY_METHOD, isCardEnabled: this.state.paymentType == CARD_TYPE });
    };

    render() {
        let pickerView;
        if (Platform.OS === 'ios') {
            pickerView = <View style={{ flexDirection: "column", justifyContent: "space-between" }}>
                <Text style={{ fontSize: 16, textAlignVertical: "center" }}> Select Payment Type: </Text>
                <PickerIOS
                    selectedValue={this.state.paymentType}
                    onValueChange={(itemValue, itemIndex) =>
                        this.setState({ paymentType: itemValue })
                    }>
                    <PickerIOS.Item label="Net Banking" value={NET_BANKING_TYPE} />
                    <PickerIOS.Item label="Debit/Credit Card" value={CARD_TYPE} />
                </PickerIOS>
            </View>
        } else {
            pickerView = <View style={{ flexDirection: "row", justifyContent: "space-between", marginBottom: 10 }}>
                <Text style={{ fontSize: 16, textAlignVertical: "center" }}> Select Payment Type: </Text>
                <Picker
                    selectedValue={this.state.paymentType}
                    style={{ height: 50, width: 150 }}
                    mode="dropdown"
                    onValueChange={(itemValue, itemIndex) =>
                        this.setState({ paymentType: itemValue })
                    }>
                    <Picker.Item label="Net Banking" value={NET_BANKING_TYPE} />
                    <Picker.Item label="Debit/Credit Card" value={CARD_TYPE} />
                </Picker>
            </View>
        }
        return (
            <>
                <SafeAreaView style={styles.container}>
                    {pickerView}
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
                    {this.renderOperationTypes(this.state.availableMinkasu2FAOperationTypes)}
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