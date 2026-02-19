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

  /// Third line of the street address.
  ///
  /// This field is optional and can be null.
  final String? line3;

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
    this.line3,
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
      'line3': line3,
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
  /// This field can not be empty or null
  final String firstName;

  /// The customer's last name.
  ///
  /// This field is optional but non-nullable. If not provided, defaults to an empty string.
  final String lastName;

  /// The customer's middle name.
  ///
  /// This field is optional and can be null.
  final String? middleName;

  /// The customer's email address.
  ///
  /// Must be a valid email address format and cannot be null.
  final String email;

  /// The customer's phone number.
  ///
  /// Must be a valid Indian phone number with +91 prefix.
  /// If prefix is not provided, it will be automatically added.
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
  ///   phone: '9876543210',  // Will be converted to '+919876543210'
  /// );
  /// ```
  ///
  /// Throws [ArgumentError] if:
  ///   - Phone number is invalid (not 10 digits)
  ///   - Email format is invalid
  ///   - First name is empty
  Minkasu2FACustomerInfo({
    required this.firstName,
    this.lastName = "",
    this.middleName,
    required this.email,
    required String phone,
    this.address,
  }) : phone = _formatPhoneNumber(phone) {
    validate();
  }

  /// Formats the phone number by adding +91 prefix if not present.
  ///
  /// Throws [ArgumentError] if phone number is invalid.
  static String _formatPhoneNumber(String phone) {
    // Remove any whitespace, hyphens, or other separators
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-()]'), '');

    // If already has +91 prefix
    if (cleanPhone.startsWith('+91')) {
      if (cleanPhone.length != 13) {
        // +91 + 10 digits
        throw ArgumentError('Phone number must be 10 digits long');
      }
      return cleanPhone;
    }

    // If starts with 91 without +
    if (cleanPhone.startsWith('91')) {
      if (cleanPhone.length != 12) {
        // 91 + 10 digits
        throw ArgumentError('Phone number must be 10 digits long');
      }
      return '+$cleanPhone';
    }

    // For just the 10-digit number
    if (cleanPhone.length != 10) {
      throw ArgumentError('Phone number must be 10 digits long');
    }

    // Validate that the phone number contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanPhone)) {
      throw ArgumentError('Phone number must contain only digits');
    }

    return '+91$cleanPhone';
  }

  /// Validates the customer information.
  ///
  /// Throws [ArgumentError] if any field is invalid.
  void validate() {
    if (firstName.trim().isEmpty) {
      throw ArgumentError('First name cannot be empty');
    }

    // Email validation using regex
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(email)) {
      throw ArgumentError('Invalid email format');
    }

    if (!phone.startsWith('+91') || phone.length != 13) {
      throw ArgumentError('Invalid phone number format');
    }
  }

  /// Converts the [Minkasu2FACustomerInfo] information to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
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
  /// Throws [ArgumentError] if:
  ///   - orderId is empty
  ///   - orderDetails is provided but it is not a json string
  Minkasu2FAOrderInfo({
    required this.orderId,
    this.orderDetails,
    this.billingCategory,
  }) {
    validate();
  }

  /// Validates the order information.
  ///
  /// Throws [ArgumentError] if orderDetails is not a json string.
  void validate() {
    if (orderId.trim().isEmpty) {
      throw ArgumentError('Order id cannot be empty');
    }

    if (orderDetails != null && orderDetails!.isNotEmpty) {
      final _ = jsonDecode(orderDetails!);
    }
  }

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
  }) {
    validate();
  }

  /// Validates the merchant information.
  ///
  /// Throws [ArgumentError] if any on the fields are invalid.
  void validate() {
    if (merchantId.trim().isEmpty) {
      throw ArgumentError('Merchant id cannot be empty');
    }

    if (merchantName.trim().isEmpty) {
      throw ArgumentError('Merchant name cannot be empty');
    }
  }

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

  /// The partner info details.
  ///
  /// This field is optional and can be null.
  final Minkasu2FAPartnerInfo? partnerInfo;

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
  /// If not provided, defaults to sandbox
  final Minkasu2FASDKMode sdkMode;

  /// The custome theme for navigation bar.
  ///
  /// This field is optional and can be null.
  final Minkasu2FACustomTheme? customTheme;

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
  /// Throws [ArgumentError] if:
  ///   - id is empty
  ///   - merchant customer id is empty
  ///   - token is empty

  Minkasu2FAConfig({
    required this.id,
    required this.merchantCustomerId,
    required this.customerInfo,
    required this.orderInfo,
    required this.token,
    this.sdkMode = Minkasu2FASDKMode.production,
    this.customTheme,
    this.partnerInfo,
  }) {
    validate();
  }

  /// Validates the config information.
  ///
  /// Throws [ArgumentError] if any field is invalid.
  void validate() {
    if (id.trim().isEmpty) {
      throw ArgumentError('id cannot be empty');
    }

    if (merchantCustomerId.trim().isEmpty) {
      throw ArgumentError('Merchant customer id cannot be empty');
    }

    if (token.trim().isEmpty) {
      throw ArgumentError('Token cannot be empty');
    }
  }

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
      'partnerInfo': partnerInfo?.toMap(),
    };
  }
}
