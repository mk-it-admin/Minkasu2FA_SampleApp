import React, { Component } from 'react';
import { SafeAreaView, View, Alert, StyleSheet } from 'react-native';
import Minkasu2FAWebView, { Minkasu2FAUIConstants } from 'react-native-minkasu2fa-webview';

export default class Minkasu2FAMethodFlowComponent extends Component {

    static navigationOptions = {
        title: 'Minkasu 2FA Method Flow'
    };

    state = {
        sourceUrl: undefined
    }

    webview = null;
    isCardEnabled = false;

    componentDidMount() {
        try {
            const { route } = this.props;
            let isConfigObj = false;
            if (route && route.params) {
                let configObj = route.params.configObj;
                this.isCardEnabled = route.params.isCardEnabled;
                if (configObj && this.webview) {
                    isConfigObj = true;
                    this.webview.initMinkasu2FA(configObj);
                }
            }
            if (!isConfigObj) {
                this.setSourceUrl();
            }
        }
        catch (e) {
            console.log(e.getMessage());
        }
    }

    setSourceUrl = () => {
        let url;
        if (this.isCardEnabled) {
            url = { uri: "https://sandbox.minkasupay.com/demo/Welcome_to_Net.html?minkasu2FA=true" };
        } else {
            url = { uri: "https://sandbox.minkasupay.com/demo/Bank_Internet_Banking_login.htm" }
        }
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