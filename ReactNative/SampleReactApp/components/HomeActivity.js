import React, { Component } from 'react';
import { SafeAreaView, View, Text, Button, StyleSheet, Platform } from 'react-native';
import { Minkasu2FAUIConstants, Minkasu2FAWebViewModule, Minkasu2FAModuleConstants } from 'react-native-minkasu2fa-webview';
import { Picker, PickerIOS } from '@react-native-community/picker';
const MERCHANT_CUSTOMER_ID = "<merchant_customer_id>";
const NET_BANKING_TYPE = 1;
const CARD_TYPE = 2;
export default class Home extends Component {

    static navigationOptions = {
    };

    state = {
        availableMinkasu2FAOperationTypes: {},
        paymentType: NET_BANKING_TYPE
    };

    async performMinkasu2FAOperation(opType) {
        try {
            if (Platform.OS == 'ios') {
                await Minkasu2FAWebViewModule.performMinkasu2FAOperation(MERCHANT_CUSTOMER_ID, opType, this.getiOSThemeObj());
            } else {
                await Minkasu2FAWebViewModule.performMinkasu2FAOperation(MERCHANT_CUSTOMER_ID, opType);
            }
            this.setState({ availableMinkasu2FAOperationTypes: {} });
        }
        catch (e) {
            console.log(e.getMessage());
        }
    }

    showMinkasuMenu() {
        Minkasu2FAWebViewModule.getMinkasu2FAOperationTypes()
            .then((data) => {
                this.setState({ availableMinkasu2FAOperationTypes: data });
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
        if (opTypes[Minkasu2FAModuleConstants.CHANGE_PIN]) {
            changePinBtn = <Button title={opTypes[Minkasu2FAModuleConstants.CHANGE_PIN]} style={{ padding: 10 }}
                onPress={() => {
                    this.performMinkasu2FAOperation(opTypes[Minkasu2FAModuleConstants.CHANGE_PIN])
                }} />
        }
        let enableDisableBiometricBtn;
        if (opTypes[Minkasu2FAModuleConstants.ENABLE_BIOMETRIC]) {
            enableDisableBiometricBtn = <Button title={opTypes[Minkasu2FAModuleConstants.ENABLE_BIOMETRIC]} style={{ padding: 10 }}
                onPress={() => {
                    this.performMinkasu2FAOperation(opTypes[Minkasu2FAModuleConstants.ENABLE_BIOMETRIC]);
                }} />
        } else if (opTypes[Minkasu2FAModuleConstants.DISABLE_BIOMETRIC]) {
            enableDisableBiometricBtn = <Button title={opTypes[Minkasu2FAModuleConstants.DISABLE_BIOMETRIC]} style={{ padding: 10 }}
                onPress={() => {
                    this.performMinkasu2FAOperation(opTypes[Minkasu2FAModuleConstants.DISABLE_BIOMETRIC]);
                }} />
        }
        return <View style={{ flexDirection: "row", marginTop: 10, justifyContent: 'space-between' }}>
            {changePinBtn}
            {enableDisableBiometricBtn}
        </View>
    }

    createMinkasuConfigObj = () => {
        let customerInfo = {
            [Minkasu2FAUIConstants.CUSTOMER_FIRST_NAME]: "TestFirstName",
            [Minkasu2FAUIConstants.CUSTOMER_LAST_NAME]: "TestLastName",
            [Minkasu2FAUIConstants.CUSTOMER_EMAIL]: "test@xyz.com",
            [Minkasu2FAUIConstants.CUSTOMER_PHONE]: "<mobile_no>" // Format: +91XXXXXXXXXX (no spaces)
        };
        let addressInfo = {
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_LINE_1]: "123 Test Way",
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_LINE_2]: "Test Apartments",
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_CITY]: "Mumbai",
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_STATE]: "Maharastra",// Unabbreviated e.g. Maharashtra (not MH)
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_COUNTRY]: "India",
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_ZIP_CODE]: "400068"// Format: XXXXXX (no spaces)
        };
        let orderInfo = {
            [Minkasu2FAUIConstants.CUSTOMER_ORDER_ID]: "<order_id>" // The order id is used to later identify
        };
        let configObj = {
            [Minkasu2FAUIConstants.MERCHANT_ID]: "<merchant_id>",
            [Minkasu2FAUIConstants.MERCHANT_TOKEN]: "<merchant_token>",
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
        this.props.navigation.navigate('Minkasu2FAAttributeFlow', { configObj: this.createMinkasuConfigObj(), initType: Minkasu2FAUIConstants.INIT_BY_ATTRIBUTE, isCardEnabled: this.state.paymentType == CARD_TYPE });
    };

    payByMethod = () => {
        this.props.navigation.navigate('Minkasu2FAMethodFlow', { configObj: this.createMinkasuConfigObj(), initType: Minkasu2FAUIConstants.INIT_BY_METHOD, isCardEnabled: this.state.paymentType == CARD_TYPE });
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