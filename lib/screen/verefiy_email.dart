import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/image_strings.dart';
import 'package:flutter_application_2/login.dart';
import 'package:flutter_application_2/screen/secces_screen.dart';
import 'package:flutter_application_2/screen/size.dart';
import 'package:flutter_application_2/screen/text_strings.dart';

import 'package:get/get.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(CupertinoIcons.clear))
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(children: [
              //image
              const SizedBox(
                height: 120,
              ),
              const Image(
                image: AssetImage(TImages.deliveredEmailIllustration),
                width: 100,
              ),
              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),

              // title and sub title

              Text(
                TTexts.confirmEmailTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),
              Text(
                'aminebekkaye@gmail.com',
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),
              Text(
                TTexts.confirmEmailSubTitle,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 80),

              // buttons
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () {
                      FirebaseAuth.instance.currentUser!
                          .sendEmailVerification();
                    },
                    child: const Text(
                      'send email confirme message',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
            ]),
          ),
        ));
  }
}
