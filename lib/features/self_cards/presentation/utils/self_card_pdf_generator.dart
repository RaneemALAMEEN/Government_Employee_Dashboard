import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../../shared/utils/app_file_downloader.dart';
import '../../domain/entities/self_card_entity.dart';

class SelfCardPdfGenerator {
  SelfCardPdfGenerator._();

  static Future<Uint8List> _loadFontBytes(
    String primaryAsset, [
    String? secondaryAsset,
  ]) async {
    try {
      final ByteData byteData = await rootBundle.load(primaryAsset);
      return byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
    } catch (_) {
      if (secondaryAsset != null) {
        try {
          final ByteData fallbackData = await rootBundle.load(secondaryAsset);
          return fallbackData.buffer.asUint8List(
            fallbackData.offsetInBytes,
            fallbackData.lengthInBytes,
          );
        } catch (_) {}
      }
      // Last resort fallback
      final ByteData lastResort =
          await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      return lastResort.buffer.asUint8List(
        lastResort.offsetInBytes,
        lastResort.lengthInBytes,
      );
    }
  }

  static Future<String> generateAndSave(SelfCardEntity selfCard) async {
    final document = PdfDocument();
    document.pageSettings.margins.all = 30;
    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.orientation = PdfPageOrientation.portrait;

    try {
      // 1. Load Arabic TrueType Fonts with complete Arabic glyph tables (Arial/Tahoma)
      final regularFontBytes = await _loadFontBytes(
        'assets/fonts/Arial-Regular.ttf',
        'assets/fonts/Tahoma-Regular.ttf',
      );
      final boldFontBytes = await _loadFontBytes(
        'assets/fonts/Arial-Bold.ttf',
        'assets/fonts/Tahoma-Bold.ttf',
      );

      final fontRegularSmall = PdfTrueTypeFont(
        regularFontBytes,
        8.5,
      );
      final fontRegular = PdfTrueTypeFont(
        regularFontBytes,
        9.5,
      );
      final fontBold = PdfTrueTypeFont(
        boldFontBytes,
        10.0,
      );
      final fontTitle = PdfTrueTypeFont(
        boldFontBytes,
        14.0,
      );
      final fontSubtitle = PdfTrueTypeFont(
        boldFontBytes,
        10.5,
      );

      // 2. Setup formatters
      final rtlRightFormat = PdfStringFormat(
        textDirection: PdfTextDirection.rightToLeft,
        alignment: PdfTextAlignment.right,
        lineAlignment: PdfVerticalAlignment.middle,
      );
      final rtlCenterFormat = PdfStringFormat(
        textDirection: PdfTextDirection.rightToLeft,
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      );
      final rtlLeftFormat = PdfStringFormat(
        textDirection: PdfTextDirection.rightToLeft,
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.middle,
      );

      // Colors
      final forestColor = PdfColor(5, 66, 57);
      final goldColor = PdfColor(185, 167, 121);
      final goldLightColor = PdfColor(248, 246, 240);
      final textDarkColor = PdfColor(25, 25, 25);
      final textMutedColor = PdfColor(90, 90, 90);
      final borderColor = PdfColor(215, 210, 198);
      final whiteColor = PdfColor(255, 255, 255);

      var page = document.pages.add();
      var graphics = page.graphics;
      final pageSize = page.getClientSize();

      double currentY = 0;

      // 3. Draw Header
      // Top Header Box with Gold Border Accent
      final headerRect = Rect.fromLTWH(0, currentY, pageSize.width, 72);
      graphics.drawRectangle(
        brush: PdfSolidBrush(goldLightColor),
        pen: PdfPen(goldColor, width: 1.5),
        bounds: headerRect,
      );

      // Right Column in Header: Official State text
      graphics.drawString(
        'الجمهورية العربية السورية\nوزارة التربية',
        fontBold,
        brush: PdfSolidBrush(forestColor),
        bounds: Rect.fromLTWH(
          pageSize.width - 210,
          currentY + 12,
          200,
          48,
        ),
        format: rtlRightFormat,
      );

      // Center Title: البطاقة الذاتية للموظف
      graphics.drawString(
        'البطاقة الذاتية للموظف',
        fontTitle,
        brush: PdfSolidBrush(forestColor),
        bounds: Rect.fromLTWH(
          (pageSize.width - 260) / 2,
          currentY + 12,
          260,
          26,
        ),
        format: rtlCenterFormat,
      );

      // Sub-badge under title
      final statusText = selfCard.isActive
          ? 'الحالة: على رأس عمله (نشط)'
          : 'الحالة: غير نشط';
      graphics.drawString(
        statusText,
        fontBold,
        brush: PdfSolidBrush(forestColor),
        bounds: Rect.fromLTWH(
          (pageSize.width - 260) / 2,
          currentY + 40,
          260,
          18,
        ),
        format: rtlCenterFormat,
      );

      // Left Column in Header: Export Date
      final now = DateTime.now();
      final dateStr =
          'تاريخ الاستخراج:\n${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
      graphics.drawString(
        dateStr,
        fontRegularSmall,
        brush: PdfSolidBrush(textMutedColor),
        bounds: Rect.fromLTWH(12, currentY + 16, 170, 40),
        format: rtlLeftFormat,
      );

      currentY += 84;

      // 4. Section 1: Personal Info Table
      _drawSectionTitle(
        graphics: graphics,
        title: 'أولاً: المعلومات الشخصية',
        y: currentY,
        width: pageSize.width,
        font: fontSubtitle,
        bgBrush: PdfSolidBrush(forestColor),
        textBrush: PdfSolidBrush(whiteColor),
        format: rtlRightFormat,
      );
      currentY += 26;

      final personalGrid = PdfGrid();
      personalGrid.columns.add(count: 4);
      personalGrid.columns[0].width = pageSize.width * 0.32; // Value 2
      personalGrid.columns[1].width = pageSize.width * 0.18; // Label 2
      personalGrid.columns[2].width = pageSize.width * 0.32; // Value 1
      personalGrid.columns[3].width = pageSize.width * 0.18; // Label 1

      _addGridRow(
        grid: personalGrid,
        label1: 'الاسم الكامل:',
        value1: _val(selfCard.fullName),
        label2: 'اسم الأب:',
        value2: _val(selfCard.fatherName),
        fontLabel: fontBold,
        fontValue: fontRegular,
        rtlFormat: rtlRightFormat,
        labelBgColor: goldLightColor,
        borderColor: borderColor,
        labelTextColor: forestColor,
        valueTextColor: textDarkColor,
      );

      _addGridRow(
        grid: personalGrid,
        label1: 'اسم الأم:',
        value1: _val(selfCard.motherName),
        label2: 'الجنس:',
        value2: _formatGender(selfCard.gender),
        fontLabel: fontBold,
        fontValue: fontRegular,
        rtlFormat: rtlRightFormat,
        labelBgColor: goldLightColor,
        borderColor: borderColor,
        labelTextColor: forestColor,
        valueTextColor: textDarkColor,
      );

      _addGridRow(
        grid: personalGrid,
        label1: 'تاريخ الميلاد:',
        value1: _val(selfCard.birthDate),
        label2: 'مكان الميلاد:',
        value2: _val(selfCard.birthPlace),
        fontLabel: fontBold,
        fontValue: fontRegular,
        rtlFormat: rtlRightFormat,
        labelBgColor: goldLightColor,
        borderColor: borderColor,
        labelTextColor: forestColor,
        valueTextColor: textDarkColor,
      );

      _addGridRow(
        grid: personalGrid,
        label1: 'الجنسية:',
        value1: _val(selfCard.nationality, fallback: 'سورية'),
        label2: 'مكان ورقم السجل:',
        value2: _formatRegistry(selfCard.registryPlace, selfCard.registryNumber),
        fontLabel: fontBold,
        fontValue: fontRegular,
        rtlFormat: rtlRightFormat,
        labelBgColor: goldLightColor,
        borderColor: borderColor,
        labelTextColor: forestColor,
        valueTextColor: textDarkColor,
      );

      final personalGridResult = personalGrid.draw(
        page: page,
        bounds: Rect.fromLTWH(0, currentY, pageSize.width, 0),
      );
      currentY = personalGridResult!.bounds.bottom + 16;

      // 5. Section 2: Job & Educational Info Table
      _drawSectionTitle(
        graphics: page.graphics,
        title: 'ثانياً: المعلومات الوظيفية والشهادات',
        y: currentY,
        width: pageSize.width,
        font: fontSubtitle,
        bgBrush: PdfSolidBrush(forestColor),
        textBrush: PdfSolidBrush(whiteColor),
        format: rtlRightFormat,
      );
      currentY += 26;

      final jobGrid = PdfGrid();
      jobGrid.columns.add(count: 4);
      jobGrid.columns[0].width = pageSize.width * 0.32; // Value 2
      jobGrid.columns[1].width = pageSize.width * 0.18; // Label 2
      jobGrid.columns[2].width = pageSize.width * 0.32; // Value 1
      jobGrid.columns[3].width = pageSize.width * 0.18; // Label 1

      _addGridRow(
        grid: jobGrid,
        label1: 'الرقم الذاتي:',
        value1: _val(selfCard.selfNumber),
        label2: 'الرقم الوطني:',
        value2: _val(selfCard.nationalId),
        fontLabel: fontBold,
        fontValue: fontRegular,
        rtlFormat: rtlRightFormat,
        labelBgColor: goldLightColor,
        borderColor: borderColor,
        labelTextColor: forestColor,
        valueTextColor: textDarkColor,
      );

      _addGridRow(
        grid: jobGrid,
        label1: 'رقم التأمين:',
        value1: _val(selfCard.insuranceNumber),
        label2: 'الشهادة العلمية:',
        value2: _val(selfCard.educationDegree),
        fontLabel: fontBold,
        fontValue: fontRegular,
        rtlFormat: rtlRightFormat,
        labelBgColor: goldLightColor,
        borderColor: borderColor,
        labelTextColor: forestColor,
        valueTextColor: textDarkColor,
      );

      _addGridRow(
        grid: jobGrid,
        label1: 'اللغة الأجنبية:',
        value1: _val(selfCard.foreignLanguage),
        label2: 'مكان الإقامة الحالي:',
        value2: _val(selfCard.currentResidence),
        fontLabel: fontBold,
        fontValue: fontRegular,
        rtlFormat: rtlRightFormat,
        labelBgColor: goldLightColor,
        borderColor: borderColor,
        labelTextColor: forestColor,
        valueTextColor: textDarkColor,
      );

      final jobGridResult = jobGrid.draw(
        page: page,
        bounds: Rect.fromLTWH(0, currentY, pageSize.width, 0),
      );
      currentY = jobGridResult!.bounds.bottom + 16;

      // 6. Section 3: Training Courses
      _drawSectionTitle(
        graphics: page.graphics,
        title: 'ثالثاً: الدورات التدريبية المعتمدة',
        y: currentY,
        width: pageSize.width,
        font: fontSubtitle,
        bgBrush: PdfSolidBrush(forestColor),
        textBrush: PdfSolidBrush(whiteColor),
        format: rtlRightFormat,
      );
      currentY += 26;

      if (selfCard.trainingCourses.isEmpty) {
        final emptyBoxRect = Rect.fromLTWH(0, currentY, pageSize.width, 36);
        page.graphics.drawRectangle(
          brush: PdfSolidBrush(whiteColor),
          pen: PdfPen(borderColor, width: 1),
          bounds: emptyBoxRect,
        );
        page.graphics.drawString(
          'لا توجد دورات تدريبية مسجلة لهذا الموظف في السجلات الحالية.',
          fontRegular,
          brush: PdfSolidBrush(textMutedColor),
          bounds: emptyBoxRect,
          format: rtlCenterFormat,
        );
      } else {
        // Build Courses Table
        final coursesGrid = PdfGrid();
        coursesGrid.columns.add(count: 7);
        coursesGrid.columns[0].width = pageSize.width * 0.12; // الملاحظات
        coursesGrid.columns[1].width = pageSize.width * 0.12; // رقم الشهادة
        coursesGrid.columns[2].width = pageSize.width * 0.10; // المدة
        coursesGrid.columns[3].width = pageSize.width * 0.14; // الفترة
        coursesGrid.columns[4].width = pageSize.width * 0.15; // الموضوع
        coursesGrid.columns[5].width = pageSize.width * 0.15; // الجهة
        coursesGrid.columns[6].width = pageSize.width * 0.22; // عنوان الدورة

        // Header
        final headerRow = coursesGrid.headers.add(1)[0];
        final headersTitles = [
          'الملاحظات',
          'رقم الشهادة',
          'المدة',
          'الفترة',
          'الموضوع',
          'الجهة المنظمة',
          'عنوان الدورة',
        ];

        for (var i = 0; i < 7; i++) {
          headerRow.cells[i].value = headersTitles[i];
          headerRow.cells[i].stringFormat = rtlCenterFormat;
          headerRow.cells[i].style.font = fontBold;
          headerRow.cells[i].style.backgroundBrush = PdfSolidBrush(goldLightColor);
          headerRow.cells[i].style.textBrush = PdfSolidBrush(forestColor);
          headerRow.cells[i].style.borders.all = PdfPen(borderColor, width: 1);
          headerRow.cells[i].style.cellPadding = PdfPaddings(left: 4, right: 4, top: 5, bottom: 5);
        }

        // Data Rows
        for (var i = 0; i < selfCard.trainingCourses.length; i++) {
          final course = selfCard.trainingCourses[i];
          final row = coursesGrid.rows.add();
          final isEven = i % 2 == 0;
          final rowBg = isEven ? whiteColor : PdfColor(252, 251, 248);

          final dateRange = (course.startDate != null && course.startDate!.trim().isNotEmpty)
              ? '${course.startDate}${course.endDate != null && course.endDate!.trim().isNotEmpty ? " - ${course.endDate}" : ""}'
              : '-';

          final values = [
            _val(course.notes),
            _val(course.certificateNumber),
            _val(course.duration),
            dateRange,
            _val(course.topic),
            _val(course.provider),
            _val(course.title),
          ];

          for (var j = 0; j < 7; j++) {
            row.cells[j].value = values[j];
            row.cells[j].stringFormat = j == 6 ? rtlRightFormat : rtlCenterFormat;
            row.cells[j].style.font = fontRegularSmall;
            row.cells[j].style.backgroundBrush = PdfSolidBrush(rowBg);
            row.cells[j].style.textBrush = PdfSolidBrush(textDarkColor);
            row.cells[j].style.borders.all = PdfPen(borderColor, width: 0.8);
            row.cells[j].style.cellPadding = PdfPaddings(left: 4, right: 4, top: 4, bottom: 4);
          }
        }

        coursesGrid.draw(
          page: page,
          bounds: Rect.fromLTWH(0, currentY, pageSize.width, 0),
        );
      }

      // 7. Draw Footers on all pages
      final pageCount = document.pages.count;
      for (var i = 0; i < pageCount; i++) {
        final p = document.pages[i];
        final pSize = p.getClientSize();
        final footerY = pSize.height - 18;

        p.graphics.drawLine(
          PdfPen(borderColor, width: 0.8),
          Offset(0, footerY - 4),
          Offset(pSize.width, footerY - 4),
        );

        p.graphics.drawString(
          'مستند رسمي صادر عن مديرية التربية - صفحة ${i + 1} من $pageCount',
          fontRegularSmall,
          brush: PdfSolidBrush(textMutedColor),
          bounds: Rect.fromLTWH(0, footerY, pSize.width, 16),
          format: rtlCenterFormat,
        );
      }

      // 8. Save to app download directory
      final pdfBytes = await document.save();
      final dir = await AppFileDownloader.getAppDownloadsDir();

      final cleanName = selfCard.fullName.trim().replaceAll(RegExp(r'[\\/:*?"<>| ]'), '_');
      final fileName = 'self_card_${selfCard.id}_$cleanName.pdf';
      final file = File('${dir.path}${Platform.pathSeparator}$fileName');

      await file.writeAsBytes(pdfBytes, flush: true);
      debugPrint('[SelfCardPdfGenerator] PDF saved successfully to: ${file.path}');
      return file.path;
    } finally {
      document.dispose();
    }
  }

  static void _drawSectionTitle({
    required PdfGraphics graphics,
    required String title,
    required double y,
    required double width,
    required PdfFont font,
    required PdfBrush bgBrush,
    required PdfBrush textBrush,
    required PdfStringFormat format,
  }) {
    final rect = Rect.fromLTWH(0, y, width, 24);
    graphics.drawRectangle(brush: bgBrush, bounds: rect);
    graphics.drawString(
      title,
      font,
      brush: textBrush,
      bounds: Rect.fromLTWH(10, y + 3, width - 20, 18),
      format: format,
    );
  }

  static void _addGridRow({
    required PdfGrid grid,
    required String label1,
    required String value1,
    required String label2,
    required String value2,
    required PdfFont fontLabel,
    required PdfFont fontValue,
    required PdfStringFormat rtlFormat,
    required PdfColor labelBgColor,
    required PdfColor borderColor,
    required PdfColor labelTextColor,
    required PdfColor valueTextColor,
  }) {
    final row = grid.rows.add();

    // Column 0: Value 2 (Leftmost in RTL layout)
    row.cells[0].value = value2;
    row.cells[0].stringFormat = rtlFormat;
    row.cells[0].style.font = fontValue;
    row.cells[0].style.textBrush = PdfSolidBrush(valueTextColor);
    row.cells[0].style.borders.all = PdfPen(borderColor, width: 0.8);
    row.cells[0].style.cellPadding = PdfPaddings(left: 6, right: 6, top: 5, bottom: 5);

    // Column 1: Label 2
    row.cells[1].value = label2;
    row.cells[1].stringFormat = rtlFormat;
    row.cells[1].style.font = fontLabel;
    row.cells[1].style.backgroundBrush = PdfSolidBrush(labelBgColor);
    row.cells[1].style.textBrush = PdfSolidBrush(labelTextColor);
    row.cells[1].style.borders.all = PdfPen(borderColor, width: 0.8);
    row.cells[1].style.cellPadding = PdfPaddings(left: 6, right: 6, top: 5, bottom: 5);

    // Column 2: Value 1
    row.cells[2].value = value1;
    row.cells[2].stringFormat = rtlFormat;
    row.cells[2].style.font = fontValue;
    row.cells[2].style.textBrush = PdfSolidBrush(valueTextColor);
    row.cells[2].style.borders.all = PdfPen(borderColor, width: 0.8);
    row.cells[2].style.cellPadding = PdfPaddings(left: 6, right: 6, top: 5, bottom: 5);

    // Column 3: Label 1 (Rightmost in RTL layout)
    row.cells[3].value = label1;
    row.cells[3].stringFormat = rtlFormat;
    row.cells[3].style.font = fontLabel;
    row.cells[3].style.backgroundBrush = PdfSolidBrush(labelBgColor);
    row.cells[3].style.textBrush = PdfSolidBrush(labelTextColor);
    row.cells[3].style.borders.all = PdfPen(borderColor, width: 0.8);
    row.cells[3].style.cellPadding = PdfPaddings(left: 6, right: 6, top: 5, bottom: 5);
  }

  static String _val(String? value, {String fallback = '-'}) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value.trim();
  }

  static String _formatRegistry(String? place, String? number) {
    final p = place?.trim();
    final n = number?.trim();
    if ((p == null || p.isEmpty) && (n == null || n.isEmpty)) return '-';
    if (p != null && p.isNotEmpty && n != null && n.isNotEmpty) return '$p / $n';
    return p ?? n ?? '-';
  }

  static String _formatGender(String? gender) {
    if (gender == null || gender.trim().isEmpty) return '-';
    final g = gender.toLowerCase().trim();
    if (g == 'male' || g == 'ذكر') return 'ذكر';
    if (g == 'female' || g == 'أنثى') return 'أنثى';
    return gender.trim();
  }
}
