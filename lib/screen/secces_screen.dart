import 'package:flutter/material.dart';
import 'package:flutter_application_2/screen/size.dart';
import 'package:flutter_application_2/screen/text_strings.dart';

class SuccesScreen extends StatelessWidget {
  const SuccesScreen(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.onPressed,
      required this.image});

  final String image, title, subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //image
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              Center(
                child: Image(
                  image: AssetImage(image),
                  width: 100,
                ),
              ),
              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),

              // title and sub title

              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),

              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),

              //button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: onPressed, child: const Text(TTexts.tContinue)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
