class InstructionsModel {
  int? status;
  String? success;
  List<InstructionData>? data;

  InstructionsModel({this.status, this.success, this.data});

  InstructionsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    if (json['data'] != null) {
      data = <InstructionData>[];
      json['data'].forEach((v) {
        data!.add(InstructionData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['status'] = status;
    json['success'] = success;
    if (data != null) {
      json['data'] = data!.map((v) => v.toJson()).toList();
    }
    return json;
  }
}

class InstructionData {
  String? slug;
  String? type;
  String? pdfUrl;
  dynamic legacyPdfUrl;
  TitleModel? title;
  TitleModel? navLabel;

  StepsModel? steps;
  SectionsModel? sections;

  InstructionData({
    this.slug,
    this.type,
    this.pdfUrl,
    this.legacyPdfUrl,
    this.title,
    this.navLabel,
    this.steps,
    this.sections,
  });

  InstructionData.fromJson(Map<String, dynamic> json) {
    slug = json['slug'];
    type = json['type'];
    pdfUrl = json['pdf_url'];
    legacyPdfUrl = json['legacy_pdf_url'];
    title =
    json['title'] != null ? TitleModel.fromJson(json['title']) : null;
    navLabel =
    json['nav_label'] != null ? TitleModel.fromJson(json['nav_label']) : null;

    steps = json['steps'] != null ? StepsModel.fromJson(json['steps']) : null;
    sections =
    json['sections'] != null ? SectionsModel.fromJson(json['sections']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['slug'] = slug;
    json['type'] = type;
    json['pdf_url'] = pdfUrl;
    json['legacy_pdf_url'] = legacyPdfUrl;
    if (title != null) json['title'] = title!.toJson();
    if (navLabel != null) json['nav_label'] = navLabel!.toJson();
    if (steps != null) json['steps'] = steps!.toJson();
    if (sections != null) json['sections'] = sections!.toJson();
    return json;
  }
}

class TitleModel {
  String? en;
  String? fr;

  TitleModel({this.en, this.fr});

  TitleModel.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    fr = json['fr'];
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'fr': fr,
    };
  }
}

/// ================== STEPS ==================

class StepsModel {
  List<StepItem>? en;
  List<StepItem>? fr;

  StepsModel({this.en, this.fr});

  StepsModel.fromJson(Map<String, dynamic> json) {
    if (json['en'] != null) {
      en = <StepItem>[];
      json['en'].forEach((v) {
        en!.add(StepItem.fromJson(v));
      });
    }
    if (json['fr'] != null) {
      fr = <StepItem>[];
      json['fr'].forEach((v) {
        fr!.add(StepItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (en != null) json['en'] = en!.map((v) => v.toJson()).toList();
    if (fr != null) json['fr'] = fr!.map((v) => v.toJson()).toList();
    return json;
  }
}

class StepItem {
  String? question;
  String? answer;
  String? questionHtml;
  String? answerHtml;

  StepItem({
    this.question,
    this.answer,
    this.questionHtml,
    this.answerHtml,
  });

  StepItem.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    answer = json['answer'];
    questionHtml = json['question_html'];
    answerHtml = json['answer_html'];
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'question_html': questionHtml,
      'answer_html': answerHtml,
    };
  }
}

/// ================== SECTIONS ==================

class SectionsModel {
  List<SectionItem>? en;
  List<SectionItem>? fr;

  SectionsModel({this.en, this.fr});

  SectionsModel.fromJson(Map<String, dynamic> json) {
    if (json['en'] != null) {
      en = <SectionItem>[];
      json['en'].forEach((v) {
        en!.add(SectionItem.fromJson(v));
      });
    }
    if (json['fr'] != null) {
      fr = <SectionItem>[];
      json['fr'].forEach((v) {
        fr!.add(SectionItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (en != null) json['en'] = en!.map((v) => v.toJson()).toList();
    if (fr != null) json['fr'] = fr!.map((v) => v.toJson()).toList();
    return json;
  }
}

class SectionItem {
  String? title;
  List<SectionStep>? steps;

  SectionItem({this.title, this.steps});

  SectionItem.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    if (json['steps'] != null) {
      steps = <SectionStep>[];
      json['steps'].forEach((v) {
        steps!.add(SectionStep.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['title'] = title;
    if (steps != null) {
      json['steps'] = steps!.map((v) => v.toJson()).toList();
    }
    return json;
  }
}

class SectionStep {
  String? text;
  String? textHtml;
  String? screenshot;
  String? screenshotUrl;

  SectionStep({
    this.text,
    this.textHtml,
    this.screenshot,
    this.screenshotUrl,
  });

  SectionStep.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    textHtml = json['text_html'];
    screenshot = json['screenshot'];
    screenshotUrl = json['screenshot_url'];
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'text_html': textHtml,
      'screenshot': screenshot,
      'screenshot_url': screenshotUrl,
    };
  }
}