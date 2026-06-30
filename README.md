# Ameen

Ameen is a Flutter banking app prototype. It presents a dark themed mobile banking experience with home dashboard actions, transfers, bill payments, account opening, service shortcuts, and an assistant floating action button.

## Current App Structure

The app starts from `lib/main.dart` with a simple login and demo OTP flow. After login, it opens the authenticated app shell in `lib/main_screen.dart`, which uses a bottom navigation layout with these main sections:

- Home
- Transfer
- Pay
- Store
- Servics

The app theme uses a dark background with gold accent colors.

## Current Pages

### Login

Files:

- `lib/features/auth/login_screen.dart`
- `lib/features/auth/login_otp_screen.dart`

Current login flow:

1. Enter the demo username `lara`.
2. Enter the demo password `123456`.
3. Firebase sends an SMS OTP to the saved phone number in `login_screen.dart`.
4. Enter the SMS OTP from your phone.
5. Open the main banking app.

Before testing, replace `_savedPhoneNumber` in `lib/features/auth/login_screen.dart` with your real phone number in international format, for example `+9665XXXXXXXX`.

### Home

File: `lib/features/home/home_screen.dart`

The Home screen shows:

- Greeting and account balance
- Main account number preview
- Quick actions for Transfer, Bills, Cards, and Products
- Advertisement containers for:
  - Visa Cards
  - Car Finance
  - Property Finance

The Bills quick action opens the same bills flow used by the Pay tab.

### Transfer

Files:

- `lib/features/transfer/transfer_screen.dart`
- `lib/features/transfer/beneficiary_screen.dart`
- `lib/features/transfer/transfer_details_screen.dart`
- `lib/features/transfer/review_screen.dart`
- `lib/features/transfer/otp_screen.dart`
- `lib/features/transfer/success_screen.dart`

Current transfer flow:

1. Select or enter transfer information.
2. Choose beneficiary and transfer type.
3. Enter transfer details such as source account, amount, reason, and note.
4. Review the transfer.
5. Confirm using OTP.
6. Show transfer success page.

### Pay / Bills

Files:

- `lib/features/bills/bills_screen.dart`
- `lib/features/bills/bill.dart`
- `lib/features/bills/bill_payment.dart`
- `lib/features/bills/bill_payment_details_screen.dart`
- `lib/features/bills/bill_review_screen.dart`
- `lib/features/bills/bill_otp_screen.dart`
- `lib/features/bills/bill_success_screen.dart`

Current bills flow:

1. Open Pay from the bottom navigation or Bills from Home quick actions.
2. View bill service categories:
   - Add New Bill
   - One Time Payment
   - Traffic Violation
   - SADAD Government
3. View saved bills list.
4. Tap a bill to show actions:
   - Pay the bill
   - Manage the bill
5. Choose an account and payment amount.
6. Review payment details.
7. Confirm using OTP.
8. Show bill payment success page.

Sample saved bills are currently stored locally in `bill.dart`.

### Accounts

Files:

- `lib/features/accounts/accounts_screen.dart`
- `lib/features/accounts/open_account_screen.dart`
- `lib/features/accounts/review_account_screen.dart`
- `lib/features/accounts/account_otp_screen.dart`
- `lib/features/accounts/account_success_screen.dart`
- `lib/features/accounts/account_application.dart`

Current accounts flow:

1. Open Accounts from the Servics page.
2. View account overview.
3. Start open new account flow.
4. Choose account type, currency, and short name.
5. Review account details.
6. Confirm using OTP.
7. Show account opened success page.

### Servics

File: `lib/features/ai/ai_screen.dart`

The Servics tab shows a grid of available service shortcuts:

- Accounts
- Cards
- Finance
- Investment
- Saving Certificate
- Insurance

Accounts opens the Accounts page. Other services currently show a selected message.

### Store

File: `lib/features/products/products_screen.dart`

The Store page is currently a placeholder screen.

### AI Assistant Button

File: `lib/main.dart`

The authenticated app shell includes a floating microphone button positioned above the bottom navigation bar. The button is currently visual only and does not open a completed assistant flow yet.

## Current Services

Implemented or partially implemented services:

- Account overview and account opening
- Simple login with Firebase phone OTP verification
- Transfer flow with review, OTP, and success
- Bill payment flow with categories, saved bills, review, OTP, and success
- Service shortcut grid
- Home advertisements for cards and finance products

Placeholder services:

- Cards
- Finance
- Investment
- Saving Certificate
- Insurance
- Store products
- AI assistant behavior

## Project Structure

```text
lib/
  main.dart
  features/
    accounts/
    ai/
    bills/
    home/
    products/
    transfer/
```

## Run The App

Install dependencies:

```bash
flutter pub get
```

List available devices:

```bash
flutter devices
```

Run on the selected device:

```bash
flutter run
```

Analyze the project:

```bash
flutter analyze
```

Format code:

```bash
dart format lib
```

## Notes

- This is currently a prototype with local sample data.
- No custom backend or real payment integration is connected yet.
- Login OTP is verified through Firebase Phone Authentication.
- Transfer, account, and bill OTP screens still validate only that 6 digits are entered.
- Most service data is hardcoded in the Flutter screens and models.
