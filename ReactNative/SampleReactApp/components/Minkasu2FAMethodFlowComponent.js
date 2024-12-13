import React, { Component } from 'react';
import { SafeAreaView, View, Alert, StyleSheet } from 'react-native';
import WebView from 'react-native-webview';

const Minkasu2FA = WebView.Minkasu2FA;
let Minkasu2FAConstants = Minkasu2FA.Constants;

export default class Minkasu2FAMethodFlowComponent extends Component {

    static navigationOptions = {
        title: 'Minkasu 2FA Method Flow'
    }

    constructor(props) {
        super(props);
        this.webView = React.createRef();
        this.state = {
            sourceUrl: undefined,
            configObj: null,
            isCardEnabled: false
        }
    }

    componentDidMount() {
        try {
            const { route } = this.props;
            if (route && route.params) {
                this.setState({ configObj: route.params.configObj, isCardEnabled: route.params.isCardEnabled }, () => {
                    if (!this.state.configObj || this.state.configObj == null) {
                        this.setSourceUrl();
                    } else if (this.webView) {
                        this.webView.current.initMinkasu2FA(this.state.configObj);
                    }
                })
            }
            console.log('Component mounted');
        }
        catch (e) {
            console.log(e.getMessage());
        }
    }

    setSourceUrl = () => {
        let url;
        let bankPhoneNumber = "";
        if (this.state.configObj != null) {
            bankPhoneNumber = this.state.configObj[Minkasu2FAConstants.CUSTOMER_INFO][Minkasu2FAConstants.CUSTOMER_PHONE];
            if (bankPhoneNumber != null && bankPhoneNumber.length > 0) {
                bankPhoneNumber = encodeURIComponent(bankPhoneNumber);
            }
        }
        if (this.state.isCardEnabled) {
            url = { uri: "https://sandbox.minkasupay.com/demo/Welcome_to_Net.html?bankPhone=" + bankPhoneNumber };
        } else {
            url = { uri: "https://sandbox.minkasupay.com/demo/Bank_Internet_Banking_login.htm?bankPhone=" + bankPhoneNumber }
        }
        this.setState({ sourceUrl: url });
    }

    onMinkasu2FAInit = (event) => {
        const data = event.nativeEvent;
        let errorMessage;
        //console.log("Minkasu Initialization", data);
        if (data) {
            const status = data[Minkasu2FAConstants.STATUS];
            if (!status || (status && status == Minkasu2FAConstants.STATUS_FAILURE)) {
                errorMessage = "";
                if (data[Minkasu2FAConstants.ERROR_CODE]) {
                    errorMessage = data[Minkasu2FAConstants.ERROR_CODE] + " : ";
                }
                errorMessage += data[Minkasu2FAConstants.ERROR_MESSAGE];
            }
        } else {
            errorMessage = "Minkasu 2FA is not initialized";
        }
        if (errorMessage)
            Alert.alert("Error", errorMessage);
        this.setSourceUrl();
    };

    onMinkasu2FAResult = (event) => {
        const data = event.nativeEvent;
        //console.log("Minkasu Result", data);
        let infoType = data[Minkasu2FAConstants.RESULT_INFO_TYPE];
        let resultData = data[Minkasu2FAConstants.RESULT_DATA];
        let result = resultData ? JSON.parse(resultData) : null;
        if (infoType && result) {
            if (infoType == Minkasu2FAConstants.INFO_TYPE_EVENT) {
                /*
                {
                    "reference_id": "<minkasu_transaction_ref>",  // UUID string
                    "screen": "<FTU_SETUP_CODE_SCREEN|FTU_AUTH_SCREEN|REPEAT_AUTH_SCREEN>", // Refer Native Doc For
                    "event": "<ENTRY>"
                }
                */
                console.log("Minkasu Info Event", result);
            } else if (infoType == Minkasu2FAConstants.INFO_TYPE_PROGRESS) {
                /*
                {
                    "reference_id": "<minkasu_transaction_ref>",  // UUID string
                    "visibility": "<true/false>",
                    "start_timer": "<true/false>",
                    "redirect_url_loading":"<true/false>"
                }
                */
                console.log("Minkasu Info Progress", result);

            } else if (infoType == Minkasu2FAConstants.INFO_TYPE_RESULT) {
                /*
                {
                    "reference_id": "<minkasu_transaction_ref>",  // UUID string
                    "status": "<SUCCESS|FAILED|TIMEOUT|CANCELLED|DISABLED>", 
                    "source": "<SDK|SERVER|BANK>", 
                    "code": <result/error code>, // 0 => Status SUCCESS, Non-zero values => Other status
                    "message": "<result/error message>"
                }
                */
                console.log("Minkasu Info Result", result);
            }
        }
    }

    render() {
        //console.log('Rendered');
        return (
            <>
                <SafeAreaView style={styles.container}>
                    <View style={{ flex: 1, justifyContent: "flex-start", backgroundColor: '#444' }}>
                        <WebView
                            ref={this.webView}
                            source={this.state.sourceUrl}
                            javaScriptEnabled={true}
                            onLoadStart={(event) => {
                                console.log("onLoadStart", event.nativeEvent);
                            }}
                            onMinkasu2FAInit={this.onMinkasu2FAInit}
                            onMinkasu2FAResult={this.onMinkasu2FAResult}
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