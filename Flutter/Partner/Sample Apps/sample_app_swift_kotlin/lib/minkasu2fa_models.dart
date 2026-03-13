import 'dart:ui';
import 'dart:convert';

enum Minkasu2FASDKMode {
  production(0),
  sandbox(1);

  const Minkasu2FASDKMode(this.value);

  final int value;

  /// Converts an integer value to its corresponding [Minkasu2FASDKMode] enum.
  ///
  /// Parameters:
  ///   - value: The integer value to convert
  ///
  /// Returns:
  ///   The corresponding [Minkasu2FASDKMode] enum value
  ///
  /// Throws:
  ///   - [ArgumentError] if the value doesn't match any enum value
  static Minkasu2FASDKMode fromValue(int value) {
    try {
      return Minkasu2FASDKMode.values.firstWhere((mode) => mode.value == value);
    } catch (e) {
      throw ArgumentError(
        'Invalid sdk mode value: $value. Valid values are: '
        '${Minkasu2FASDKMode.values.map((b) => b.value).join(', ')}',
      );
    }
  }
}

/// A model class representing a physical address.
///
/// This class stores address details including street address lines,
/// city, state, zip code, and country.
class Minkasu2FAAddress {
  /// First line of the street address.
  ///
  /// This field is optional and can be null.
  final String? line1;

  /// Second line of the street address.
  ///
  /// This field is optional and can be null.
  final String? line2;

  /// Name of the city.
  ///
  /// This field is optional and can be null.
  final String? city;

  /// Name of the state.
  ///
  /// This field is optional and can be null.
  final String? state;

  /// Zip Code.
  ///
  /// This field is optional and can be null.
  final String? zipCode;

  /// Name of the country.
  ///
  /// This field is optional and can be null.
  final String? country;

  /// Creates a new [Minkasu2FAAddress] instance.
  ///
  /// All the fields are optional but should be provided when available.
  ///
  /// Example:
  /// ```dart
  /// final address = Minkasu2FAAddress(
  ///   line1: '123 Test way',
  ///   line2: 'Test Soc',
  ///   city: 'Mumbai',
  ///   state: 'Maharashtra',
  ///   zipCode: "400068",
  ///   country: "India",
  /// );
  /// ```
  ///
  const Minkasu2FAAddress({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.zipCode,
    this.country,
  });

  /// Converts the [Minkasu2FAAddress] information to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }
}

/// Specific for iOS only
/// A model class representing a custom theme for a navigation bar.
/// This class defines both light and dark mode colors for a navigation bar and
/// includes support for toggling dark mode.
class Minkasu2FACustomTheme {
  /// The background color of the navigation bar in light mode.
  ///
  /// This field is required and can not be null.
  final Color navigationBarColor;

  /// The text color of the navigation bar in light mode.
  ///
  /// This field is required and can not be null.
  final Color navigationBarTextColor;

  /// The background color of the navigation bar in dark mode.
  ///
  /// This field is optional but non-nullable. If not provided, defaults to [navigationBarColor].
  final Color darkModeNavigationBarColor;

  /// The text color of the navigation bar in dark mode.
  ///
  /// This field is optional but non-nullable. If not provided, defaults to [navigationBarTextColor].
  final Color darkModeNavigationBarTextColor;

  /// Whether dark mode is supported by this theme.
  ///
  /// Defaults to false if not provided.
  final bool supportDarkMode;

  /// Creates a [Minkasu2FACustomTheme] with the given light and dark mode properties.
  ///
  /// If [darkModeNavigationBarColor] or [darkModeNavigationBarTextColor] are not provided,
  /// they default to the values of [navigationBarColor] and [navigationBarTextColor] respectively.
  /// Example:
  /// ```dart
  /// final theme = Minkasu2FACustomTheme(
  ///   navigationBarColor: Colors.white,
  ///   navigationBarTextColor: Colors.white,
  /// );
  /// ```
  ///
  const Minkasu2FACustomTheme({
    required this.navigationBarColor,
    required this.navigationBarTextColor,
    Color? darkModeNavigationBarColor,
    Color? darkModeNavigationBarTextColor,
    this.supportDarkMode = false,
  }) : darkModeNavigationBarColor =
           darkModeNavigationBarColor ?? navigationBarColor,
       darkModeNavigationBarTextColor =
           darkModeNavigationBarTextColor ?? navigationBarTextColor;

  /// Converts the [Minkasu2FACustomTheme] information to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'navigationBarColor': navigationBarColor.value,
      'navigationBarTextColor': navigationBarTextColor.value,
      'darkModeNavigationBarColor': darkModeNavigationBarColor.value,
      'darkModeNavigationBarTextColor': darkModeNavigationBarTextColor.value,
      'supportDarkMode': supportDarkMode,
    };
  }
}

/// A model class representing customer information.
///
/// This class stores essential customer details including name, contact information,
class Minkasu2FACustomerInfo {
  /// The customer's first name
  ///
  /// If not provided, it will be automatically set to an empty string.
  final String? firstName;

  /// The customer's last name.
  ///
  /// If not provided, it will be automatically set to an empty string.
  final String? lastName;

  /// The customer's email address.
  ///
  /// If not provided, it will be automatically set to an empty string.
  final String? email;

  /// The customer's phone number.
  ///
  /// Must be a valid Indian phone number with +91 prefix.
  final String phone;

  /// The customer's address.
  ///
  /// This field is optional and can be null.
  final Minkasu2FAAddress? address;

  /// Creates a new [Minkasu2FACustomerInfo] instance.
  ///
  /// The phone number will automatically be formatted with +91 prefix if not present.
  ///
  /// Example:
  /// ```dart
  /// final customer = Minkasu2FACustomerInfo(
  ///   firstName: 'John',
  ///   lastName: 'Doe',
  ///   email: 'john.doe@example.com',
  ///   phone: '+919876543210',
  /// );
  /// ```
  ///
  Minkasu2FACustomerInfo({
    this.firstName,
    this.lastName,
    this.email,
    required this.phone,
    this.address,
  });

  /// Converts the [Minkasu2FACustomerInfo] information to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address?.toMap(),
    };
  }
}

/// A model class representing order informations.
///
/// This class stores details about an order, including its ID, optional details,
/// and an optional billing category.
class Minkasu2FAOrderInfo {
  /// The unique identifier for the order.
  ///
  /// This field can not be empty or null
  final String orderId;

  /// Additional details about the order, stored as a JSON string (optional).
  ///
  /// This field is optional and can be null.
  final String? orderDetails;

  /// The billing category associated with the order (optional).
  ///
  /// This field is optional and can be null.
  final String? billingCategory;

  /// Creates a new [Minkasu2FAOrderInfo] instance.
  ///
  /// Example:
  /// ```dart
  /// final order = Minkasu2FAOrderInfo(
  ///   orderId: '12345',
  ///   orderDetails: jsonEncode({
  ///     'item': 'Laptop',
  ///     'quantity': 1,
  ///     'price': 1500.0,
  ///   }),
  /// );
  /// ```
  ///
  Minkasu2FAOrderInfo({
    required this.orderId,
    this.orderDetails,
    this.billingCategory,
  });

  /// Converts the [Minkasu2FAOrderInfo] information to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'orderDetails': orderDetails,
      'billingCategory': billingCategory,
    };
  }
}

/// A model class representing partner information.
///
/// This class contains details about the partner.
class Minkasu2FAPartnerInfo {
  /// The unique identifier for the merchant.
  ///
  /// This field can not be empty or null
  final String merchantId;

  /// The name of the merchant.
  ///
  /// This field can not be empty or null
  final String merchantName;

  /// The transaction identifier associated with the merchant
  ///
  /// This field is optional and can be null.
  final String? transactionId;

  /// Creates an instance of [Minkasu2FAPartnerInfo].
  /// Example:
  /// ```dart
  /// final partner = Minkasu2FAPartnerInfo(
  ///   merchantId: '12345',
  ///   merchantName: 'Test Merchant',
  /// );
  /// ```
  ///
  /// Throws [ArgumentError] if:
  ///   - merchantId is empty
  ///   - merchant name is empty
  Minkasu2FAPartnerInfo({
    required this.merchantId,
    required this.merchantName,
    this.transactionId,
  });

  /// Converts the [Minkasu2FAPartnerInfo] information to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'merchantName': merchantName,
      'transactionId': transactionId,
    };
  }
}

/// A model class representing config information.
///
/// This class encapsulates all the required and optional configuration
/// parameters needed to initialize and use the Minkasu 2FA SDK.
class Minkasu2FAConfig {
  /// The id provided by MinkasuPay
  ///
  /// This field is required and can not be null.
  final String id;

  /// The merchant's customer identifier.
  ///
  /// This field is required and can not be null.
  final String merchantCustomerId;

  /// The customer's information.
  ///
  /// This field is required and can not be null.
  final Minkasu2FACustomerInfo customerInfo;

  /// The order information.
  ///
  /// This field is required and can not be null.
  final Minkasu2FAOrderInfo orderInfo;

  /// The token provided by MinkasuPay
  ///
  /// This field is required and can not be null.
  final String token;

  /// The SDK mode (sandbox or production).
  ///
  /// If not provided, defaults to production
  final Minkasu2FASDKMode sdkMode;

  /// The custome theme for navigation bar.
  ///
  /// This field is optional and can be null.
  final Minkasu2FACustomTheme? customTheme;

  /// The partner info details.
  ///
  /// This field is optional and can be null.
  final Minkasu2FAPartnerInfo? partnerInfo;

  /// Creates a new [Minkasu2FAConfig] instance.
  ///
  /// Example:
  /// ```dart
  /// final customer = Minkasu2FACustomerInfo(
  ///   firstName: 'John',
  ///   lastName: 'Doe',
  ///   email: 'john.doe@example.com',
  ///   phone: '9876543210',  // Will be converted to '+919876543210'
  /// );
  /// final order = Minkasu2FAOrderInfo(
  ///   orderId: '12345',
  ///   orderDetails: jsonEncode({
  ///     'item': 'Laptop',
  ///     'quantity': 1,
  ///     'price': 1500.0,
  ///   }),
  /// );
  /// final config = Minkasu2FAConfig(
  ///   id: '12345',
  ///   merchantCustomerId: 'MC_001',
  ///   customerInfo: customer,
  ///   orderInfo: order,
  ///   token: 'sdnejne4n1243n3b4122dmska23asd'
  /// );
  /// ```
  ///

  Minkasu2FAConfig({
    required this.id,
    required this.merchantCustomerId,
    required this.customerInfo,
    required this.orderInfo,
    required this.token,
    this.sdkMode = Minkasu2FASDKMode.production,
    this.customTheme,
    this.partnerInfo,
  });

  /// Converts the [Minkasu2FAConfig] information to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchantCustomerId': merchantCustomerId,
      'customerInfo': customerInfo.toMap(),
      'orderInfo': orderInfo.toMap(),
      'token': token,
      'sdkMode': sdkMode.value,
      'customTheme': customTheme?.toMap(),
    };
  }
}
