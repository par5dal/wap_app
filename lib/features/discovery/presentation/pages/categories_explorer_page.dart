// lib/features/discovery/presentation/pages/categories_explorer_page.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/router/app_router.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/discovery/data/datasources/discovery_remote_data_source.dart';
import 'package:wap_app/features/discovery/data/models/category_model.dart';
import 'package:wap_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:wap_app/shared/widgets/custom_app_bar.dart';

class CategoriesExplorerPage extends StatefulWidget {
  const CategoriesExplorerPage({super.key});

  @override
  State<CategoriesExplorerPage> createState() => _CategoriesExplorerPageState();
}

class _CategoriesExplorerPageState extends State<CategoriesExplorerPage>
    with TickerProviderStateMixin {
  final DiscoveryRemoteDataSource _dataSource = DiscoveryRemoteDataSourceImpl(
    dio: sl<Dio>(),
  );

  List<CategoryModel> categories = [];
  bool isLoading = true;
  String? error;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadCategories();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await _dataSource.getCategories(
        limit: 100, // Cargar todas las categorías
      );
      setState(() {
        categories = response.data;
      });

      // Animar la entrada de las categorías
      _animationController.forward();
    } catch (e) {
      setState(() {
        error = context.l10n.categoriesError;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: context.l10n.categoriesTitle,
        showBackButton: true,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error!,
              style: context.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCategories,
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      );
    }

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: context.colorScheme.onSurface.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.categoriesEmpty,
              style: context.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _animationController,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 0.8,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final delay = index * 0.1;

                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final animationValue = Curves.easeOutCubic.transform(
                      (((_animationController.value * 2) - delay).clamp(
                        0.0,
                        1.0,
                      )),
                    );

                    return Transform.scale(
                      scale: animationValue,
                      child: _CircularCategoryItem(category: category),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CircularCategoryItem extends StatefulWidget {
  final CategoryModel category;

  const _CircularCategoryItem({required this.category});

  @override
  State<_CircularCategoryItem> createState() => _CircularCategoryItemState();
}

class _CircularCategoryItemState extends State<_CircularCategoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Color get iconColor {
    try {
      return Color(int.parse(widget.category.color.replaceFirst('#', '0xff')));
    } catch (e) {
      return context.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      onTap: () {
        // Obtener la ubicación del usuario del HomeBloc si está disponible
        final homeState = sl<HomeBloc>().state;
        final userLocation = homeState.userLocation;

        context.pushNamed(
          AppRoute.categoryEvents.name,
          pathParameters: {'slug': widget.category.slug},
          extra: {'category': widget.category, 'userLocation': userLocation},
        );
      },
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Círculo blanco con ícono
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: widget.category.svg.isNotEmpty
                        ? SvgPicture.string(
                            widget.category.svg,
                            width: 32,
                            height: 32,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          )
                        : Icon(Icons.category, color: iconColor, size: 32),
                  ),
                ),

                const SizedBox(height: 12),

                // Texto de la categoría
                Text(
                  widget.category.name.toUpperCase(),
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.onSurface,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
