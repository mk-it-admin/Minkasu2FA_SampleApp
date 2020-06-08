import React, { Component } from 'react';
import { SafeAreaView, View, Alert, StyleSheet } from 'react-native';
import Minkasu2FAWebView, { Minkasu2FAUIConstants } from 'react-native-minkasu2fa-webview';

export default class Minkasu2FAAttributeFlowComponent extends Component {

    static navigationOptions = {
        title: 'Minkasu 2FA Attribute Flow'
    }

    state = {
        sourceUrl: undefined
    }

    configObj = null;
    webview = null;

    constructor(props) {
        super(props);
        const { route } = this.props;
        if (route && route.params) {
            this.configObj = route.params.configObj;
        }
    }

    componentDidMount() {
        if (this.configObj == null) {
            this.setSourceUrl();
        }
    }

    setSourceUrl = () => {
        const url = { uri: "https://sandbox.minkasupay.com/demo/Bank_Internet_Banking_login.htm" };
        this.setState({ sourceUrl: url });
    }

    onMinkasu2FAInit = (event) => {
        const data = event.nativeEvent;
        let errorMessage;
        if (data) {
            const status = data[Minkasu2FAUIConstants.STATUS];
            if (!status || (status && status == Minkasu2FAUIConstants.STATUS_FAILURE)) {
                errorMessage = "";
                if (data[Minkasu2FAUIConstants.ERROR_CODE]) {
                    errorMessage = data[Minkasu2FAUIConstants.ERROR_CODE] + " : ";
                }
                errorMessage += data[Minkasu2FAUIConstants.ERROR_MESSAGE];
            }
        } else {
            errorMessage = "Minkasu 2FA is not initialized";
        }
        if (errorMessage)
            Alert.alert("Error", errorMessage);
        this.setSourceUrl();
    };

    render() {
        return (
            <>
                <SafeAreaView style={styles.container}>
                    <View style={{ flex: 1, justifyContent: "flex-start", backgroundColor: '#444' }}>
                        <Minkasu2FAWebView
                            ref={ref => (this.webview = ref)}
                            source={this.state.sourceUrl}
                            javaScriptEnabled={true}
                            minkasu2FAConfig={this.configObj}
                            onMinkasu2FAInit={this.onMinkasu2FAInit}
                        />
                    </View>
                </SafeAreaView>
            </>
        );
    };
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