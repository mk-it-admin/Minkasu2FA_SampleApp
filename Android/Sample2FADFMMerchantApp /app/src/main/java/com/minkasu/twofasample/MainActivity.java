package com.minkasu.twofasample;

import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;

import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.google.android.material.navigation.NavigationView;
import com.google.android.play.core.splitcompat.SplitCompat;

import java.util.List;

public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {
    public static final String MERCHANT_CUSTOMER_ID = "C_1";
    private Minkasu2faDFMInterface minkasu2faDFMInterface;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);
        hideItems();
        Menu nav_Menu = navigationView.getMenu();
        nav_Menu.performIdentifierAction(R.id.nav_auth_pay, 0);
    }

    @Override
    protected void onResume() {
        super.onResume();
        hideItems();
    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }

    private void hideItems() {
        NavigationView navigationView = findViewById(R.id.nav_view);
        Menu nav_Menu = navigationView.getMenu();
        nav_Menu.findItem(R.id.nav_change_pin).setVisible(false);
        nav_Menu.findItem(R.id.nav_enablebiometrics).setVisible(false);
        nav_Menu.findItem(R.id.nav_disablebiometrics).setVisible(false);
        if (MERCHANT_CUSTOMER_ID.length() <= 0) {
            return;
        }
        try {
            initializeMinkasu2faDFMInterface();
            if (minkasu2faDFMInterface != null) {
                List<String> operationTypes = minkasu2faDFMInterface.getAvailableMinkasu2FAOperation(getApplicationContext());
                for (String opType : operationTypes) {
                    MenuItem item = null;
                    switch (opType) {
                        case Minkasu2faDFMInterface.CHANGE_PAYPIN:
                            item = nav_Menu.findItem(R.id.nav_change_pin).setVisible(true);
                            break;
                        case Minkasu2faDFMInterface.ENABLE_BIOMETRICS:
                            item = nav_Menu.findItem(R.id.nav_enablebiometrics).setVisible(true);
                            break;
                        case Minkasu2faDFMInterface.DISABLE_BIOMETRICS:
                            item = nav_Menu.findItem(R.id.nav_disablebiometrics).setVisible(true);
                            break;
                    }
                    if (item != null) {
                        //set custom title string for menu item
                        item.setTitle(opType);
                    }
                }
            }
        } catch (Exception e) {
            Log.e("MainActivity", e.getMessage());
        }
    }

    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();
        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        popAllFragmentsInStack();
        if (id == R.id.nav_auth_pay) {
            getSupportFragmentManager().beginTransaction().replace(R.id.content_main, getAuthPayFragment(), "PayFragment").commit();
        } else if (id == R.id.nav_change_pin) {
            performMinkasu2faOperation(Minkasu2faDFMInterface.CHANGE_PAYPIN);
        } else if (id == R.id.nav_enablebiometrics) {
            performMinkasu2faOperation(Minkasu2faDFMInterface.ENABLE_BIOMETRICS);
        } else if (id == R.id.nav_disablebiometrics) {
            performMinkasu2faOperation(Minkasu2faDFMInterface.DISABLE_BIOMETRICS);
        }
        return true;
    }

    private void popAllFragmentsInStack() {
        FragmentManager fragmentManager = getSupportFragmentManager();
        int stack_size_1 = fragmentManager.getBackStackEntryCount();
        for (int i = 0; i < stack_size_1; i++) {
            fragmentManager.popBackStackImmediate();
        }
        int stack_size_2 = fragmentManager.getBackStackEntryCount();
        Log.i("MinkasuSDKActivity", "PopAllFramgents: stack size changed from " + stack_size_1
                + " to  " + stack_size_2);
    }

    private Fragment getAuthPayFragment() {
        Bundle args;
        AuthPayFragment fragment = new AuthPayFragment();
        args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    private void initializeMinkasu2faDFMInterface() {
        if (minkasu2faDFMInterface == null) {
            try {
                Class<?> minkasuDFM = Class.forName("com.minkasu.androiddfm.Minkasu2faDFM");
                minkasu2faDFMInterface = (Minkasu2faDFMInterface) minkasuDFM.getDeclaredConstructor().newInstance();
            } catch (Exception e) {
                Log.e("MainActivity", "Error in initializing Minkasu2faDFM instance. Error:" + e.getMessage());
            }
        }
    }

    private void performMinkasu2faOperation(String operationType) {
        try {
            //fetch merchantCustomerId
            if (!MERCHANT_CUSTOMER_ID.isEmpty()) {
                initializeMinkasu2faDFMInterface();
                if (minkasu2faDFMInterface != null) {
                    minkasu2faDFMInterface.performMinkasu2FAOperation(this, operationType, MERCHANT_CUSTOMER_ID);
                }
            }
        } catch (Exception e) {
            Log.i("Exception", e.toString());
        }
    }
}
