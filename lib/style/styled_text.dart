import 'package:flutter/material.dart';
//
class StyledText extends StatelessWidget {
  final String text;

  const StyledText(this.text, {super.key,});

  @override
  Widget build(BuildContext context) {
    return Text(text,style: Theme.of(context).textTheme.headlineLarge,
    );
  }
}

class BodyMedium extends StatelessWidget {
  final String text;

  const BodyMedium(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text,style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

class HeadlineMedium extends StatelessWidget {
  final String text;

  const HeadlineMedium(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text,style: Theme.of(context).textTheme.headlineMedium,
        );
  }
}

class HeadlineSmall extends StatelessWidget {
  final String text;

  const HeadlineSmall(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text,style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}

class BodySmall extends StatelessWidget {
  final String text;

  const BodySmall(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text,style: Theme.of(context).textTheme.bodySmall,
    );
  }
}


