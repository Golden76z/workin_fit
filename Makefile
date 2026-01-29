run:
	flutter run
build:
	flutter build apk
clean:
	flutter clean
test:
	flutter test

# Starting the Android Emulator
emulator:
# 	flutter emulators --launch @Pixel_5_API_34
	emulator @Pixel_5_API_34

# Re-generate the arb files
arb_gen:
	flutter gen-l10n